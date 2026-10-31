/*
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
package tech.algoriti.algoritiq_app

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings

/**
 * Deep links to maker "auto-start" / app-launch pages, with AOSP fallbacks for
 * tablets that ship without [com.hihonor.systemmanager] (near-stock Settings).
 */
object AutoStartSettings {
    /** Opens per-app battery / background controls on Android 10+. */
    private const val ACTION_ADVANCED_POWER =
        "android.settings.VIEW_ADVANCED_POWER_USAGE_DETAIL"

    private val VENDOR_MANUFACTURERS = setOf(
        "honor",
        "huawei",
        "xiaomi",
        "redmi",
        "poco",
        "oppo",
        "realme",
        "vivo",
        "iqoo",
        "samsung",
        "oneplus",
        "meizu",
        "asus",
        "letv",
    )

    private val VENDOR_COMPONENTS = listOf(
        // Honor / MagicOS (new package first)
        "com.hihonor.systemmanager" to
            "com.hihonor.systemmanager.startupmgr.ui.StartupNormalAppListActivity",
        "com.hihonor.systemmanager" to
            "com.hihonor.systemmanager.appcontrol.activity.StartupAppControlActivity",
        "com.hihonor.systemmanager" to
            "com.hihonor.systemmanager.optimize.bootstart.BootStartActivity",
        // Huawei / EMUI
        "com.huawei.systemmanager" to
            "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity",
        "com.huawei.systemmanager" to
            "com.huawei.systemmanager.appcontrol.activity.StartupAppControlActivity",
        "com.huawei.systemmanager" to
            "com.huawei.systemmanager.optimize.process.ProtectActivity",
        "com.huawei.systemmanager" to
            "com.huawei.systemmanager.optimize.bootstart.BootStartActivity",
        // Xiaomi
        "com.miui.securitycenter" to
            "com.miui.permcenter.autostart.AutoStartManagementActivity",
        // Oppo / Realme
        "com.coloros.safecenter" to
            "com.coloros.safecenter.permission.startup.StartupAppListActivity",
        // Vivo
        "com.vivo.permissionmanager" to
            "com.vivo.permissionmanager.activity.BgStartUpManagerActivity",
        // Samsung
        "com.samsung.android.lool" to
            "com.samsung.android.sm.ui.battery.BatteryActivity",
    )

    fun required(context: Context): Boolean {
        if (Build.MANUFACTURER.lowercase() !in VENDOR_MANUFACTURERS) return false
        // Show the row when a dedicated vendor page exists, or on Honor/Huawei
        // where "App launch" lives inside Settings even without Phone Manager.
        if (hasVendorStartupActivity(context)) return true
        return isHuaweiHonor()
    }

    /** First intent that the system can open, best match first. */
    fun resolveLaunchIntent(context: Context): Intent? {
        val pm = context.packageManager
        for (intent in candidateIntents(context)) {
            if (intent.resolveActivity(pm) != null) return intent
        }
        return null
    }

    fun hasVendorStartupActivity(context: Context): Boolean {
        val pm = context.packageManager
        return VENDOR_COMPONENTS.any { (pkg, cls) ->
            componentIntent(pkg, cls).resolveActivity(pm) != null
        }
    }

    private fun isHuaweiHonor(): Boolean {
        val m = Build.MANUFACTURER.lowercase()
        return m == "honor" || m == "huawei"
    }

    private fun candidateIntents(context: Context): List<Intent> {
        val pkg = context.packageName
        val vendor = VENDOR_COMPONENTS.map { (p, c) -> componentIntent(p, c) }
        val advanced = Intent(ACTION_ADVANCED_POWER).apply {
            data = Uri.parse("package:$pkg")
            addCategory(Intent.CATEGORY_DEFAULT)
        }
        val appList = Intent(Settings.ACTION_APPLICATION_SETTINGS)
        val details = appDetailsIntent(pkg)
        return vendor + listOf(advanced, appList, details)
    }

    private fun componentIntent(packageName: String, className: String) =
        Intent().setComponent(ComponentName(packageName, className))

    private fun appDetailsIntent(packageName: String) =
        Intent(
            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
            Uri.parse("package:$packageName"),
        )
}
