package tech.algoriti.algoritiq_app

import android.os.Build
import android.os.Bundle
import android.os.Process
import android.os.SystemClock
import android.view.View
import android.view.ViewTreeObserver
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        DeviceIdChannel.register(flutterEngine, applicationContext)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            holdSplashUntilAnimationEnds()
        }
    }

    /**
     * Keeps the Android 12+ splash screen up until its logo animation has
     * played once (counted from process start), so a fast start doesn't cut
     * it short. A slow start (e.g. debug build) adds no extra wait.
     */
    private fun holdSplashUntilAnimationEnds() {
        val readyAt = Process.getStartUptimeMillis() + SPLASH_ANIMATION_MS
        val content = findViewById<View>(android.R.id.content)
        val remaining = readyAt - SystemClock.uptimeMillis()
        if (remaining <= 0) return

        content.viewTreeObserver.addOnPreDrawListener(
            object : ViewTreeObserver.OnPreDrawListener {
                override fun onPreDraw(): Boolean {
                    if (SystemClock.uptimeMillis() < readyAt) return false
                    content.viewTreeObserver.removeOnPreDrawListener(this)
                    return true
                }
            },
        )
        // Trigger a new draw pass once the animation is over.
        content.postDelayed({ content.invalidate() }, remaining)
    }

    private companion object {
        /** Keep in sync with `DURATION_MS` in tool/splash_wordmark/build_vector.py. */
        const val SPLASH_ANIMATION_MS = 1000L
    }
}
