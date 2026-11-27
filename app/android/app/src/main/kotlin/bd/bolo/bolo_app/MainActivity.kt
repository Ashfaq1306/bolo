package bd.bolo.bolo_app

import android.Manifest
import android.app.KeyguardManager
import android.app.NotificationManager
import android.app.SearchManager
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import android.provider.Settings
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.speech.RecognitionService
import android.speech.SpeechRecognizer
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Bolo's bridge to the phone ("bolo/device" channel): calling, playing music,
 * opening apps, the hands-free wake word service, and showing over the lock
 * screen when the user calls Bolo by name.
 *
 * Every action here runs only because the user asked for it (by voice or tap)
 * in the Flutter UI; nothing runs in the background except the wake word
 * listener, which the user switches on in Settings.
 */
class MainActivity : FlutterActivity() {

    companion object {
        const val EXTRA_WAKE = "bolo.wake"
        private const val CHANNEL = "bolo/device"
        private const val REQ_PERMISSION = 4100

        @Volatile private var visible: MainActivity? = null

        /** Called by the wake service. True if Bolo was on screen and got the event. */
        fun deliverWake(): Boolean {
            val activity = visible ?: return false
            activity.runOnUiThread { activity.handleWake() }
            return true
        }
    }

    private var channel: MethodChannel? = null
    private var pendingWake = false
    private var pendingPermission: MethodChannel.Result? = null
    private var wakeSessionOverLock = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).also {
            it.setMethodCallHandler(::onCall)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (intent?.getBooleanExtra(EXTRA_WAKE, false) == true) prepareWake()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (intent.getBooleanExtra(EXTRA_WAKE, false)) handleWake()
    }

    override fun onResume() {
        super.onResume()
        visible = this
    }

    override fun onPause() {
        if (visible === this) visible = null
        super.onPause()
    }

    // ---------------- wake word → Bolo appears ----------------

    /** Show over the lock screen and turn the screen on for this session. */
    private fun prepareWake() {
        getSystemService(NotificationManager::class.java).cancel(7002)
        val locked = getSystemService(KeyguardManager::class.java).isKeyguardLocked
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            // Called by voice: always light the screen; show over the lock
            // screen only for this session (personal data stays hidden).
            setTurnScreenOn(true)
            if (locked) setShowWhenLocked(true)
        }
        if (locked) wakeSessionOverLock = true
        pendingWake = true
    }

    private fun handleWake() {
        prepareWake()
        val ch = channel ?: return
        pendingWake = false
        ch.invokeMethod("onWake", mapOf("locked" to wakeSessionOverLock))
    }

    private fun endWakeSession() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(false)
            setTurnScreenOn(false)
        }
        wakeSessionOverLock = false
    }

    // ---------------- method channel ----------------

    private fun onCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "consumeWake" -> {
                    val had = pendingWake
                    pendingWake = false
                    result.success(mapOf("wake" to had, "locked" to wakeSessionOverLock))
                }
                "primaryAbi" -> result.success(Build.SUPPORTED_ABIS.firstOrNull() ?: "")
                "isLocked" -> result.success(getSystemService(KeyguardManager::class.java).isKeyguardLocked)
                "requestUnlock" -> requestUnlock(result)
                "endWakeSession" -> {
                    endWakeSession()
                    result.success(null)
                }
                "requestPermission" -> requestPermission(call.argument<String>("name") ?: "", result)
                "hasPermission" -> result.success(hasPermission(call.argument<String>("name") ?: ""))
                "callNumber" -> result.success(callNumber(call.argument<String>("number") ?: ""))
                "playMedia" -> result.success(playMedia(call.argument<String>("query") ?: ""))
                "openApp" -> result.success(openApp(call.argument<String>("name") ?: ""))
                "wakeStart" -> {
                    val i = WakeWordService.intent(this, WakeWordService.ACTION_START)
                        .putExtra(WakeWordService.EXTRA_NAME, call.argument<String>("name") ?: "bolo")
                        .putExtra(WakeWordService.EXTRA_LABEL, call.argument<String>("label") ?: "Bolo")
                        .putExtra(WakeWordService.EXTRA_THRESHOLD, (call.argument<Double>("threshold") ?: 0.6).toFloat())
                    ContextCompat.startForegroundService(this, i)
                    result.success(true)
                }
                "wakeStop" -> {
                    if (WakeWordService.running) startService(WakeWordService.intent(this, WakeWordService.ACTION_STOP))
                    result.success(null)
                }
                "wakePause" -> {
                    if (WakeWordService.running) startService(WakeWordService.intent(this, WakeWordService.ACTION_PAUSE))
                    result.success(null)
                }
                "wakeResume" -> {
                    if (WakeWordService.running) startService(WakeWordService.intent(this, WakeWordService.ACTION_RESUME))
                    result.success(null)
                }
                "speechEnvironment" -> result.success(speechEnvironment())
                "wakeStatus" -> result.success(mapOf("running" to WakeWordService.running, "listening" to WakeWordService.listening))
                "wakeKnowsName" -> {
                    val name = call.argument<String>("name") ?: ""
                    Thread {
                        val ok = try { WakeModel.knows(this, name) } catch (e: Exception) { false }
                        runOnUiThread { result.success(ok) }
                    }.start()
                }
                "canAppearOverApps" -> result.success(Build.VERSION.SDK_INT < Build.VERSION_CODES.Q || Settings.canDrawOverlays(this))
                "openAppearOverAppsSettings" -> {
                    startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName")))
                    result.success(null)
                }
                "canUseFullScreen" -> result.success(
                    Build.VERSION.SDK_INT < 34 || getSystemService(NotificationManager::class.java).canUseFullScreenIntent(),
                )
                "openFullScreenSettings" -> {
                    if (Build.VERSION.SDK_INT >= 34) {
                        startActivity(Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT, Uri.parse("package:$packageName")))
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("device_error", e.message, null)
        }
    }

    private fun requestUnlock(result: MethodChannel.Result) {
        val km = getSystemService(KeyguardManager::class.java)
        if (!km.isKeyguardLocked) {
            result.success(true)
            return
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            result.success(false)
            return
        }
        km.requestDismissKeyguard(this, object : KeyguardManager.KeyguardDismissCallback() {
            override fun onDismissSucceeded() = result.success(true)
            override fun onDismissCancelled() = result.success(false)
            override fun onDismissError() = result.success(false)
        })
    }

    // ---------------- permissions ----------------

    private fun permissionFor(name: String): String? = when (name) {
        "phone" -> Manifest.permission.CALL_PHONE
        "microphone" -> Manifest.permission.RECORD_AUDIO
        "contacts" -> Manifest.permission.READ_CONTACTS
        "notifications" -> if (Build.VERSION.SDK_INT >= 33) Manifest.permission.POST_NOTIFICATIONS else null
        else -> null
    }

    private fun hasPermission(name: String): Boolean {
        val p = permissionFor(name) ?: return true
        return ContextCompat.checkSelfPermission(this, p) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestPermission(name: String, result: MethodChannel.Result) {
        val p = permissionFor(name)
        if (p == null || hasPermission(name)) {
            result.success(true)
            return
        }
        pendingPermission?.success(false)
        pendingPermission = result
        ActivityCompat.requestPermissions(this, arrayOf(p), REQ_PERMISSION)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQ_PERMISSION) {
            pendingPermission?.success(grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)
            pendingPermission = null
        }
    }

    // ---------------- actions ----------------

    /** Places the call directly if allowed, otherwise opens the dialer with the number filled in. */
    private fun callNumber(number: String): String {
        val clean = number.filter { it.isDigit() || it == '+' }
        if (clean.length < 3) return "invalid"
        val uri = Uri.fromParts("tel", clean, null)
        return if (hasPermission("phone")) {
            startActivity(Intent(Intent.ACTION_CALL, uri).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            "called"
        } else {
            startActivity(Intent(Intent.ACTION_DIAL, uri).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            "dialer"
        }
    }

    /**
     * "Play X": asks the phone's music apps (Spotify, YouTube Music, ...)
     * through Android's standard play-from-search intent; falls back to a
     * YouTube search.
     */
    private fun playMedia(query: String): String {
        val search = Intent(MediaStore.INTENT_ACTION_MEDIA_PLAY_FROM_SEARCH)
            .putExtra(SearchManager.QUERY, query)
            .putExtra(MediaStore.EXTRA_MEDIA_FOCUS, "vnd.android.cursor.item/*")
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (query.isNotBlank() && search.resolveActivity(packageManager) != null) {
            try {
                startActivity(search)
                return "player"
            } catch (_: ActivityNotFoundException) {}
        }
        val q = if (query.isBlank()) "bangla song" else query
        val yt = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.youtube.com/results?search_query=" + Uri.encode(q)))
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        return try {
            startActivity(yt)
            "youtube"
        } catch (_: ActivityNotFoundException) {
            "none"
        }
    }

    /** Opens an installed app whose name best matches [name]; returns its label or null. */
    private fun openApp(name: String): String? {
        val wanted = name.lowercase().replace(Regex("[^\\p{L}\\p{N}]"), "")
        if (wanted.isEmpty()) return null
        val pm = packageManager
        val launcher = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        val apps = pm.queryIntentActivities(launcher, 0)
        var best: Pair<String, String>? = null // label, package
        var bestScore = 0
        for (info in apps) {
            val label = info.loadLabel(pm).toString()
            val norm = label.lowercase().replace(Regex("[^\\p{L}\\p{N}]"), "")
            val score = when {
                norm == wanted -> 3
                norm.isNotEmpty() && (norm.startsWith(wanted) || wanted.startsWith(norm)) -> 2
                norm.contains(wanted) -> 1
                else -> 0
            }
            if (score > bestScore && info.activityInfo.packageName != packageName) {
                bestScore = score
                best = label to info.activityInfo.packageName
            }
        }
        val (label, pkg) = best ?: return null
        val launch = pm.getLaunchIntentForPackage(pkg) ?: return null
        startActivity(launch.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        return label
    }

    // ---------------- voice check (diagnostics) ----------------

    /**
     * Facts about the phone's speech recognition setup for the Voice check
     * screen. Shown only on the phone; nothing here is sent anywhere, and it
     * contains no audio or speech.
     */
    private fun speechEnvironment(): Map<String, Any?> {
        val pm = packageManager
        fun version(pkg: String): String? = try {
            val info = pm.getPackageInfo(pkg, 0)
            val enabled = info.applicationInfo?.enabled != false
            (info.versionName ?: "?") + if (enabled) "" else " (disabled)"
        } catch (e: PackageManager.NameNotFoundException) {
            null
        }
        val services = pm.queryIntentServices(Intent(RecognitionService.SERVICE_INTERFACE), 0)
            .mapNotNull { it.serviceInfo?.packageName }
            .distinct()
        val inputs = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            getSystemService(AudioManager::class.java).getDevices(AudioManager.GET_DEVICES_INPUTS).map {
                when (it.type) {
                    AudioDeviceInfo.TYPE_BUILTIN_MIC -> "builtin_mic"
                    AudioDeviceInfo.TYPE_BLUETOOTH_SCO -> "bluetooth"
                    AudioDeviceInfo.TYPE_WIRED_HEADSET -> "wired_headset"
                    AudioDeviceInfo.TYPE_USB_DEVICE, AudioDeviceInfo.TYPE_USB_HEADSET -> "usb"
                    else -> "type_${it.type}"
                }
            }.distinct()
        } else emptyList()
        return mapOf(
            "manufacturer" to Build.MANUFACTURER,
            "model" to Build.MODEL,
            "android" to Build.VERSION.RELEASE,
            "sdk" to Build.VERSION.SDK_INT,
            // The recognizer Android uses by default (what speech_to_text gets).
            "defaultRecognizer" to Settings.Secure.getString(contentResolver, "voice_recognition_service"),
            "recognizers" to services,
            "recognitionAvailable" to SpeechRecognizer.isRecognitionAvailable(this),
            "onDeviceAvailable" to (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                SpeechRecognizer.isOnDeviceRecognitionAvailable(this)),
            "googleApp" to version("com.google.android.googlequicksearchbox"),
            "speechServices" to version("com.google.android.tts"),
            "playServices" to version("com.google.android.gms"),
            "micInputs" to inputs,
            "wakeWordListening" to WakeWordService.listening,
        )
    }
}
