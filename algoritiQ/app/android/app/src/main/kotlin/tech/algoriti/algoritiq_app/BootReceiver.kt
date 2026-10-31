/*
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
package tech.algoriti.algoritiq_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Starts [KeepAliveService] when the tablet powers on, after an app update, or
 * when the user unlocks it.
 *
 * [Intent.ACTION_LOCKED_BOOT_COMPLETED] runs right after power-on, before a
 * PIN-locked tablet is unlocked; the app's data is in device-protected storage
 * ([AlgoritiqApplication]), so the API can start then. Until data from an
 * older version has been moved ([DeviceStorage]), the start waits for
 * [Intent.ACTION_BOOT_COMPLETED] or [Intent.ACTION_USER_PRESENT], which come
 * after the first unlock. Some makers send [QUICKBOOT_POWERON] instead.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_LOCKED_BOOT_COMPLETED,
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_USER_PRESENT,
            QUICKBOOT_POWERON -> {
                if (intent.action in BOOT_ACTIONS) AutoStartProbe.recordBootStart(context)
                if (!DeviceStorage.isReady(context)) return
                val pending = goAsync()
                try {
                    KeepAliveService.start(context)
                } catch (_: RuntimeException) {
                    // Android refused a background start (for example, battery
                    // restrictions). The readiness guide blocks until fixed.
                } finally {
                    pending.finish()
                }
            }
        }
    }

    private companion object {
        const val QUICKBOOT_POWERON = "android.intent.action.QUICKBOOT_POWERON"

        /** Sent only after a power-on: proof that auto-start works. */
        val BOOT_ACTIONS = setOf(
            Intent.ACTION_LOCKED_BOOT_COMPLETED,
            Intent.ACTION_BOOT_COMPLETED,
            QUICKBOOT_POWERON,
        )
    }
}
