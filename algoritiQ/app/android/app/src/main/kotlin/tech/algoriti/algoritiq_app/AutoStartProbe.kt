package tech.algoriti.algoritiq_app

import android.content.Context
import android.os.Build
import android.os.SystemClock
import android.provider.Settings
import java.io.File

/**
 * Whether the app may start by itself after a restart on makers with an
 * "auto-start" / app-launch manager. There is no public Android API: some
 * makers mirror the switch in Secure settings, others (the Honor Pad X7, whose
 * startup manager is reported but cannot be opened) show nothing. So the
 * reliable answer is evidence: [BootReceiver] records each restart it was
 * started for ([recordBootStart]), and the switch counts as granted when that
 * happened for the current power-on. A restart that did not start the app
 * turns the check off again.
 */
object AutoStartProbe {
    fun required(context: Context): Boolean = AutoStartSettings.required(context)

    fun granted(context: Context): Boolean {
        if (!required(context)) return true
        val pkg = context.packageName
        // App Ops "run in background" is not the vendor auto-start switch; on
        // Honor and others it is often MODE_ALLOWED by default and causes false
        // checkmarks. Only trust maker-specific settings we can read.
        if (isXiaomiFamily() && isXiaomiAutoStartEnabled(context, pkg)) return true
        if (isHuaweiHonor() && isHuaweiHonorAutoStartEnabled(context, pkg)) return true
        return startedSinceThisBoot(context)
    }

    /** Called when Android started the app for a restart. */
    fun recordBootStart(context: Context) {
        // Some tablets send the boot signal again later (for example when the
        // app is opened after being force-stopped); that proves nothing.
        if (SystemClock.elapsedRealtime() > BOOT_WINDOW_MS) return
        val boot = bootCount(context) ?: return
        try {
            evidence(context).writeText(boot.toString())
        } catch (_: Exception) {
            // Only evidence; the guide keeps asking.
        }
    }

    private fun startedSinceThisBoot(context: Context): Boolean {
        val boot = bootCount(context) ?: return false
        return try {
            evidence(context).readText().trim().toIntOrNull() == boot
        } catch (_: Exception) {
            false
        }
    }

    /** Power-ons since the tablet was set up (Android 7+). */
    private fun bootCount(context: Context): Int? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) return null
        return Settings.Global.getInt(context.contentResolver, Settings.Global.BOOT_COUNT, -1)
            .takeIf { it >= 0 }
    }

    private fun evidence(context: Context) =
        File(context.applicationContext.noBackupFilesDir, "boot_start_seen")

    /** A real start after power-on happens within minutes of it. */
    private const val BOOT_WINDOW_MS = 10 * 60 * 1000L

    private fun isHuaweiHonor(): Boolean {
        val m = Build.MANUFACTURER.lowercase()
        return m == "honor" || m == "huawei"
    }

    private fun isXiaomiFamily(): Boolean {
        val m = Build.MANUFACTURER.lowercase()
        return m == "xiaomi" || m == "redmi" || m == "poco"
    }

    /** MIUI exposes a switch in Settings; some builds mirror it here. */
    private fun isXiaomiAutoStartEnabled(context: Context, packageName: String): Boolean {
        return secureFlagEnabled(context, "autostart_$packageName")
    }

    /** Honor / EMUI sometimes mirror startup manager state in Secure settings. */
    private fun isHuaweiHonorAutoStartEnabled(context: Context, packageName: String): Boolean {
        val keys = listOf(
            "autostart_$packageName",
            "hw_app_o_authorized_$packageName",
            "startup_app_list_$packageName",
        )
        return keys.any { secureFlagEnabled(context, it) }
    }

    private fun secureFlagEnabled(context: Context, key: String): Boolean {
        return try {
            Settings.Secure.getInt(context.contentResolver, key, 0) == 1
        } catch (_: Exception) {
            false
        }
    }
}
