package bd.bolo.bolo_app

import android.content.Context
import android.util.Log
import com.sun.jna.Library
import com.sun.jna.Native
import com.sun.jna.Pointer
import org.vosk.LibVosk
import org.vosk.LogLevel
import org.vosk.Model
import java.io.File

/**
 * Loads the offline Vosk speech model used for the wake word ("Bolo").
 *
 * The model ships inside the APK (assets/vosk-model-en). Vosk needs real
 * files, so the first time we copy it to the app's private storage. Audio
 * never leaves the phone: recognition runs entirely on the device.
 */
object WakeModel {
    private const val TAG = "BoloWake"
    private const val ASSET_DIR = "vosk-model-en"

    /** Bump when the bundled model changes, so phones re-copy it. */
    private const val MODEL_VERSION = "small-en-us-0.15"

    @Volatile private var model: Model? = null

    /** Vosk's C API has a vocabulary lookup that the Java wrapper doesn't expose. */
    private interface VoskExtra : Library {
        fun vosk_model_find_word(model: Pointer, word: String): Int
    }

    private val extra: VoskExtra by lazy { Native.load("vosk", VoskExtra::class.java) }

    @Synchronized
    fun get(context: Context): Model {
        model?.let { return it }
        LibVosk.setLogLevel(LogLevel.WARNINGS)
        val dir = File(context.filesDir, ASSET_DIR)
        val marker = File(dir, ".version")
        if (!marker.exists() || marker.readText() != MODEL_VERSION) {
            dir.deleteRecursively()
            copyAssets(context, ASSET_DIR, dir)
            marker.writeText(MODEL_VERSION)
        }
        return Model(dir.absolutePath).also { model = it }
    }

    /** True if every word of [name] is in the model's vocabulary (so it can be heard). */
    fun knows(context: Context, name: String): Boolean {
        val m = get(context)
        val words = name.lowercase().trim().split(Regex("\\s+")).filter { it.isNotEmpty() }
        if (words.isEmpty()) return false
        return words.all { extra.vosk_model_find_word(m.pointer, it) >= 0 }
    }

    private fun copyAssets(context: Context, assetPath: String, target: File) {
        val children = context.assets.list(assetPath) ?: emptyArray()
        if (children.isEmpty()) {
            target.parentFile?.mkdirs()
            context.assets.open(assetPath).use { input -> target.outputStream().use { input.copyTo(it) } }
            return
        }
        target.mkdirs()
        for (child in children) copyAssets(context, "$assetPath/$child", File(target, child))
        Log.d(TAG, "copied $assetPath")
    }
}
