package bd.bolo.bolo_app

import android.app.KeyguardManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.provider.Settings
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import org.json.JSONArray
import org.json.JSONObject
import org.vosk.Recognizer
import org.vosk.android.RecognitionListener
import org.vosk.android.SpeechService
import java.util.concurrent.Executors

/**
 * Hands-free mode: listens for the assistant's name ("Bolo") with an offline
 * Vosk recogniser while the screen is on, off, or locked.
 *
 * - Runs as a foreground service with a permanent notification (Android
 *   requires this for the microphone, and it keeps the user informed).
 * - Recognition is restricted to a small grammar: the name, some common
 *   "competitor" words (so "hello" isn't heard as "bolo"), and [unk]. Tested
 *   on the PC: 11/11 wake clips detected, 0/15 false alarms.
 * - Audio is processed on the phone and immediately discarded.
 * - When the name is heard, the service stops using the mic (so the normal
 *   speech recogniser can take over) and opens Bolo, over the lock screen
 *   if needed. Bolo tells the service to resume when the conversation ends.
 */
class WakeWordService : Service(), RecognitionListener {

    companion object {
        private const val TAG = "BoloWake"
        const val ACTION_START = "bd.bolo.wake.START"
        const val ACTION_STOP = "bd.bolo.wake.STOP"
        const val ACTION_PAUSE = "bd.bolo.wake.PAUSE"
        const val ACTION_RESUME = "bd.bolo.wake.RESUME"
        const val EXTRA_NAME = "name"
        const val EXTRA_THRESHOLD = "threshold"
        const val EXTRA_LABEL = "label"

        private const val CHANNEL_LISTEN = "bolo_wake_listen"
        private const val CHANNEL_WAKE = "bolo_wake_alert"
        private const val NOTIF_LISTEN = 7001
        private const val NOTIF_WAKE = 7002

        /** Common words that compete with the name inside the grammar. */
        private val DISTRACTORS = (
            "hello hi hey okay yes no below the a i you we it is to of and in for on that this what go come call play how are"
            ).split(" ")

        @Volatile var running = false
            private set
        @Volatile var listening = false
            private set

        fun intent(context: Context, action: String) = Intent(context, WakeWordService::class.java).setAction(action)
    }

    private val main = Handler(Looper.getMainLooper())
    private val worker = Executors.newSingleThreadExecutor()
    private var speech: SpeechService? = null
    private var recognizer: Recognizer? = null
    private var name = "bolo"
    private var label = "Bolo"
    private var threshold = 0.6f
    private var paused = false
    private val autoResume = Runnable { resumeListening() }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopEverything()
                return START_NOT_STICKY
            }
            ACTION_PAUSE -> {
                paused = true
                stopListening()
                // Safety net: never stay deaf forever if Bolo forgets to resume.
                main.removeCallbacks(autoResume)
                main.postDelayed(autoResume, 90_000)
                return START_STICKY
            }
            ACTION_RESUME -> {
                paused = false
                main.removeCallbacks(autoResume)
                resumeListening()
                return START_STICKY
            }
            else -> {
                // START (or a restart by the system with a null intent).
                val prefs = getSharedPreferences("bolo_wake", MODE_PRIVATE)
                intent?.getStringExtra(EXTRA_NAME)?.let { prefs.edit().putString(EXTRA_NAME, it).apply() }
                intent?.getStringExtra(EXTRA_LABEL)?.let { prefs.edit().putString(EXTRA_LABEL, it).apply() }
                if (intent?.hasExtra(EXTRA_THRESHOLD) == true) {
                    prefs.edit().putFloat(EXTRA_THRESHOLD, intent.getFloatExtra(EXTRA_THRESHOLD, 0.6f)).apply()
                }
                name = (prefs.getString(EXTRA_NAME, "bolo") ?: "bolo").lowercase().trim()
                label = prefs.getString(EXTRA_LABEL, "Bolo") ?: "Bolo"
                threshold = prefs.getFloat(EXTRA_THRESHOLD, 0.6f)
                if (!goForeground()) return START_NOT_STICKY
                running = true
                paused = false
                restartRecognizer()
                return START_STICKY
            }
        }
    }

    private fun goForeground(): Boolean {
        createChannels()
        val open = PendingIntent.getActivity(
            this, 0, Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val stop = PendingIntent.getService(
            this, 1, intent(this, ACTION_STOP), PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val n = NotificationCompat.Builder(this, CHANNEL_LISTEN)
            .setSmallIcon(R.drawable.ic_stat_bolo)
            .setContentTitle(getString(R.string.wake_listening_title, label))
            .setContentText(getString(R.string.wake_listening_text, label))
            .setOngoing(true)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(open)
            .addAction(0, getString(R.string.wake_stop), stop)
            .build()
        return try {
            ServiceCompat.startForeground(
                this, NOTIF_LISTEN, n,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE else 0,
            )
            true
        } catch (e: Exception) {
            // Android refuses a microphone service started from the background
            // (e.g. right after a reboot). Bolo restarts it when next opened.
            Log.w(TAG, "Can't start the microphone service now: $e")
            stopSelf()
            false
        }
    }

    private fun restartRecognizer() {
        worker.execute {
            try {
                val model = WakeModel.get(this)
                val words = name.split(Regex("\\s+")).filter { it.isNotEmpty() }
                val grammar = JSONArray().apply {
                    put(name)
                    DISTRACTORS.filter { it !in words }.forEach { put(it) }
                    put("[unk]")
                }
                stopListening()
                recognizer?.close()
                recognizer = Recognizer(model, 16000f, grammar.toString()).apply { setWords(true) }
                main.post { if (!paused) resumeListening() }
            } catch (e: Exception) {
                Log.e(TAG, "Wake word model failed: $e")
                main.post { stopEverything() }
            }
        }
    }

    private fun resumeListening() {
        val rec = recognizer ?: return
        if (!running || paused || speech != null) return
        try {
            rec.reset()
            speech = SpeechService(rec, 16000f).also { it.startListening(this) }
            listening = true
        } catch (e: Exception) {
            // Mic busy (a call, another recorder): try again shortly.
            Log.w(TAG, "Mic unavailable, retrying: $e")
            speech = null
            listening = false
            main.postDelayed({ resumeListening() }, 5_000)
        }
    }

    private fun stopListening() {
        speech?.let {
            it.stop()
            it.shutdown()
        }
        speech = null
        listening = false
    }

    private fun stopEverything() {
        running = false
        main.removeCallbacksAndMessages(null)
        stopListening()
        worker.execute {
            recognizer?.close()
            recognizer = null
        }
        ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        running = false
        stopListening()
        super.onDestroy()
    }

    // ---------------- recognition callbacks ----------------

    override fun onResult(hypothesis: String) = check(hypothesis)
    override fun onFinalResult(hypothesis: String) = check(hypothesis)
    override fun onPartialResult(hypothesis: String) {}
    override fun onTimeout() { resumeAfterGlitch() }
    override fun onError(exception: Exception) {
        Log.w(TAG, "Recognition error: $exception")
        resumeAfterGlitch()
    }

    private fun resumeAfterGlitch() {
        stopListening()
        main.postDelayed({ resumeListening() }, 2_000)
    }

    /** Looks for the name (all its words, in order) with enough confidence. */
    private fun check(hypothesis: String) {
        val words = try {
            JSONObject(hypothesis).optJSONArray("result") ?: return
        } catch (e: Exception) {
            return
        }
        val target = name.split(Regex("\\s+")).filter { it.isNotEmpty() }
        if (target.isEmpty()) return
        for (i in 0..words.length() - target.size) {
            var ok = true
            for (j in target.indices) {
                val w = words.getJSONObject(i + j)
                if (w.optString("word") != target[j] || w.optDouble("conf", 0.0) < threshold) {
                    ok = false
                    break
                }
            }
            if (ok) {
                main.post { onWake() }
                return
            }
        }
    }

    private fun onWake() {
        if (paused) return
        Log.i(TAG, "Wake word heard")
        paused = true
        stopListening()
        main.removeCallbacks(autoResume)
        main.postDelayed(autoResume, 90_000)
        vibrate()

        // 1) Bolo is already on screen: just tell it.
        if (MainActivity.deliverWake()) return

        // 2) Bring Bolo up. Wake the screen briefly so it's visible.
        wakeScreen()
        val launch = Intent(this, MainActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
            .putExtra(MainActivity.EXTRA_WAKE, true)
        val canStartDirectly = Build.VERSION.SDK_INT < Build.VERSION_CODES.Q || Settings.canDrawOverlays(this)
        if (canStartDirectly) {
            try {
                startActivity(launch)
                return
            } catch (e: Exception) {
                Log.w(TAG, "Direct start blocked: $e")
            }
        }
        // 3) Full-screen notification: shows Bolo over the lock screen, or a
        //    heads-up "tap to talk" banner while the phone is in use.
        val pi = PendingIntent.getActivity(this, 2, launch, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        val n = NotificationCompat.Builder(this, CHANNEL_WAKE)
            .setSmallIcon(R.drawable.ic_stat_bolo)
            .setContentTitle(getString(R.string.wake_heard_title, label))
            .setContentText(getString(R.string.wake_heard_text))
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setAutoCancel(true)
            .setTimeoutAfter(20_000)
            .setContentIntent(pi)
            .setFullScreenIntent(pi, true)
            .build()
        getSystemService(NotificationManager::class.java).notify(NOTIF_WAKE, n)
    }

    private fun wakeScreen() {
        val pm = getSystemService(PowerManager::class.java)
        if (pm.isInteractive) return
        @Suppress("DEPRECATION")
        val lock = pm.newWakeLock(
            PowerManager.SCREEN_BRIGHT_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP or PowerManager.ON_AFTER_RELEASE,
            "bolo:wake",
        )
        lock.acquire(5_000)
    }

    private fun vibrate() {
        val v = getSystemService(Vibrator::class.java) ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            v.vibrate(VibrationEffect.createOneShot(60, VibrationEffect.DEFAULT_AMPLITUDE))
        }
    }

    private fun createChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = getSystemService(NotificationManager::class.java)
        nm.createNotificationChannel(
            NotificationChannel(CHANNEL_LISTEN, getString(R.string.wake_channel_listen), NotificationManager.IMPORTANCE_LOW).apply {
                setShowBadge(false)
            },
        )
        nm.createNotificationChannel(
            NotificationChannel(CHANNEL_WAKE, getString(R.string.wake_channel_alert), NotificationManager.IMPORTANCE_HIGH).apply {
                setSound(null, null)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            },
        )
    }

    @Suppress("unused")
    private fun isLocked() = getSystemService(KeyguardManager::class.java).isKeyguardLocked
}
