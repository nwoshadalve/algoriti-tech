/*
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
package tech.algoriti.algoritiq_app

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.Process
import android.os.SystemClock
import android.view.View
import android.view.ViewTreeObserver
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

/**
 * The screen. The Flutter engine (and the local API inside it) belongs to the
 * process, not to this Activity: see [EngineHolder]. Closing the screen leaves
 * the server running.
 */
class MainActivity : FlutterActivity() {
    override fun provideFlutterEngine(context: Context): FlutterEngine =
        EngineHolder.ensure(context)

    // The engine must survive this Activity.
    override fun shouldDestroyEngineWithHost(): Boolean = false

    override fun onCreate(savedInstanceState: Bundle?) {
        EngineHolder.activity = this
        super.onCreate(savedInstanceState)
        RefreshRate.requestHighest(this)
        KeepAliveService.start(this)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            holdSplashUntilAppIsReady()
        }
    }

    override fun onDestroy() {
        if (EngineHolder.activity === this) EngineHolder.activity = null
        SplashHold.onRelease = null
        super.onDestroy()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        KeepAliveChannel.onPermissionResult(
            requestCode,
            grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED,
        )
        SystemHealthChannel.onPermissionResult(
            requestCode,
            grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED,
        )
        PrinterChannel.onPermissionResult(
            requestCode,
            grantResults.isNotEmpty() &&
                grantResults.all { it == PackageManager.PERMISSION_GRANTED },
        )
    }

    /**
     * Keeps the Android 12+ splash screen up until the logo animation has
     * played once (counted from process start) and the app has drawn its
     * first real screen, so the splash is followed directly by content, never
     * by a blank screen. [MAX_HOLD_MS] is a safety net if the app never
     * reports in. When the app was already running (the screen was only
     * closed), there is nothing to wait for.
     */
    private fun holdSplashUntilAppIsReady() {
        val started = Process.getStartUptimeMillis()
        val animationEndsAt = started + SPLASH_ANIMATION_MS
        val giveUpAt = started + MAX_HOLD_MS
        val content = findViewById<View>(android.R.id.content)

        SplashHold.onRelease = {
            // Draw again so the hold below is re-checked.
            content.invalidate()
        }
        content.viewTreeObserver.addOnPreDrawListener(
            object : ViewTreeObserver.OnPreDrawListener {
                override fun onPreDraw(): Boolean {
                    val now = SystemClock.uptimeMillis()
                    val waiting = now < animationEndsAt || !SplashHold.ready
                    if (waiting && now < giveUpAt) return false
                    content.viewTreeObserver.removeOnPreDrawListener(this)
                    return true
                }
            },
        )
        val now = SystemClock.uptimeMillis()
        content.postDelayed({ content.invalidate() }, maxOf(0L, animationEndsAt - now))
        content.postDelayed({ content.invalidate() }, maxOf(0L, giveUpAt - now))
    }

    private companion object {
        /** Keep in sync with `DURATION_MS` in tool/splash_wordmark/build_vector.py. */
        const val SPLASH_ANIMATION_MS = 1000L

        /** Never hold the splash longer than this, whatever the app does. */
        const val MAX_HOLD_MS = 10_000L
    }
}
