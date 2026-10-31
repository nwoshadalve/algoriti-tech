/*
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
package tech.algoriti.algoritiq_app

import android.app.Activity
import android.os.Build
import android.view.Display

/**
 * Asks Android to run the app at the display's highest refresh rate.
 *
 * Many tablets keep apps at 60 Hz even when the panel supports more. We only
 * pick among modes with the current resolution, so the screen never flickers
 * through a resolution switch. API 23+; older versions are left untouched.
 */
object RefreshRate {
    fun requestHighest(activity: Activity) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        @Suppress("DEPRECATION")
        val display = activity.windowManager.defaultDisplay ?: return
        val current = display.mode
        val best = bestMode(display.supportedModes.toList(), current) ?: return
        if (best.modeId == current.modeId) return

        val attrs = activity.window.attributes
        attrs.preferredDisplayModeId = best.modeId
        activity.window.attributes = attrs
    }

    /** Highest-rate mode with the same size as [current]; null if none. */
    internal fun bestMode(
        modes: List<Display.Mode>,
        current: Display.Mode,
    ): Display.Mode? = modes
        .filter {
            it.physicalWidth == current.physicalWidth &&
                it.physicalHeight == current.physicalHeight
        }
        .maxByOrNull { it.refreshRate }
}
