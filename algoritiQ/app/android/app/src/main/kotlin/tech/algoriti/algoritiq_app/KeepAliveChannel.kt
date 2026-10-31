/*
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
package tech.algoriti.algoritiq_app

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import java.net.Inet4Address
import java.net.Inet6Address
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Lets the setup guide see and fix what keeps the local API alive: the
 * background service, notification permission, battery restrictions,
 * auto-start (vendor-specific) and the screen lock. Flutter side:
 * `KeepAliveGateway`.
 *
 * Nothing here is silent: each request opens a system dialog or settings
 * page, and the user decides.
 */
class KeepAliveChannel(private val context: Context) :
    MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "status" -> result.success(status())
            "localAddresses" -> result.success(localAddresses())
            "localAddressesV6" -> result.success(localAddressesV6())
            "startService" -> {
                runCatching { KeepAliveService.start(context) }
                    .onSuccess { result.success(null) }
                    .onFailure { result.error("START_FAILED", it.message, null) }
            }
            "requestNotifications" -> requestNotifications(result)
            "requestIgnoreBatteryOptimizations" -> open(
                Intent(
                    Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                    Uri.parse("package:${context.packageName}"),
                ),
                result,
            )
            "openNotificationSettings" -> open(
                Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                    .putExtra(Settings.EXTRA_APP_PACKAGE, context.packageName),
                result,
            )
            "openAutoStartSettings" -> openAutoStart(result)
            "openAppSettings" -> open(appDetails(), result)
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        KeepAliveNetworkEvents.attachSink(events)
    }

    override fun onCancel(arguments: Any?) {
        KeepAliveNetworkEvents.attachSink(null)
    }

    private fun status(): Map<String, Any> {
        val power = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        return mapOf(
            "sdk" to Build.VERSION.SDK_INT,
            "manufacturer" to Build.MANUFACTURER.lowercase(),
            "notificationsGranted" to NotificationManagerCompat.from(context).areNotificationsEnabled(),
            "notificationsNeedPermission" to (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU),
            "batteryOptimizationIgnored" to power.isIgnoringBatteryOptimizations(context.packageName),
            "serviceRunning" to KeepAliveService.running,
            "autoStartRequired" to AutoStartProbe.required(context),
            "autoStartGranted" to AutoStartProbe.granted(context),
        )
    }

    private fun connectivity(): ConnectivityManager =
        context.applicationContext.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

    /**
     * The tablet's IPv4 addresses on its networks (Wi-Fi first). Read from the
     * system's connectivity service: Android 11+ hides interface lists from
     * the plain socket APIs.
     *
     * Prefer the [ConnectivityManager.activeNetwork] so a Wi-Fi handoff does
     * not briefly keep an old subnet address first in the list.
     */
    private fun localAddresses(): List<String> {
        val manager = connectivity()
        val active = manager.activeNetwork
        if (active != null) {
            val onActive = ipv4On(manager, active)
            if (onActive.isNotEmpty()) return onActive
        }
        return manager.allNetworks
            .sortedByDescending { wifiFirst(manager, it) }
            .flatMap { ipv4On(manager, it) }
            .distinct()
    }

    /**
     * IPv6 link-local addresses (`fe80::...`, Wi-Fi first), without the
     * `%wlan0` suffix. Windows needs one to resolve the tablet's name quickly.
     */
    private fun localAddressesV6(): List<String> {
        val manager = connectivity()
        val active = manager.activeNetwork
        if (active != null) {
            val onActive = ipv6LinkLocalOn(manager, active)
            if (onActive.isNotEmpty()) return onActive
        }
        return manager.allNetworks
            .sortedByDescending { wifiFirst(manager, it) }
            .flatMap { ipv6LinkLocalOn(manager, it) }
            .distinct()
    }

    private fun wifiFirst(manager: ConnectivityManager, network: Network): Boolean =
        manager.getNetworkCapabilities(network)
            ?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true

    private fun ipv4On(manager: ConnectivityManager, network: Network): List<String> =
        manager.getLinkProperties(network)?.linkAddresses.orEmpty()
            .map { it.address }
            .filterIsInstance<Inet4Address>()
            .filter { !it.isLoopbackAddress && !it.isLinkLocalAddress }
            .mapNotNull { it.hostAddress }

    private fun ipv6LinkLocalOn(manager: ConnectivityManager, network: Network): List<String> =
        manager.getLinkProperties(network)?.linkAddresses.orEmpty()
            .map { it.address }
            .filterIsInstance<Inet6Address>()
            .filter { it.isLinkLocalAddress }
            .mapNotNull { it.hostAddress?.substringBefore('%') }

    private fun requestNotifications(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
        ) {
            result.success(true)
            return
        }
        val activity = EngineHolder.activity
        if (activity == null) {
            result.error("NO_SCREEN", "Open the app to allow notifications.", null)
            return
        }
        pendingNotificationResult?.error("SUPERSEDED", null, null)
        pendingNotificationResult = result
        activity.requestPermissions(
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            REQUEST_NOTIFICATIONS,
        )
    }

    private fun openAutoStart(result: MethodChannel.Result) {
        val intent = AutoStartSettings.resolveLaunchIntent(context)
        if (intent != null && launch(intent)) {
            result.success("opened")
            return
        }
        open(appDetails(), result)
    }

    private fun appDetails() = Intent(
        Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
        Uri.parse("package:${context.packageName}"),
    )

    private fun open(intent: Intent, result: MethodChannel.Result) {
        if (launch(intent)) {
            result.success("opened")
        } else {
            result.error("CANNOT_OPEN", "This settings page is not available.", null)
        }
    }

    private fun launch(intent: Intent): Boolean = try {
        val activity: Activity? = EngineHolder.activity
        if (activity != null) {
            activity.startActivity(intent)
        } else {
            context.startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        }
        true
    } catch (_: RuntimeException) {
        false
    }

    companion object {
        const val NAME = "tech.algoriti.algoritiq/keepalive"
        const val EVENTS = "tech.algoriti.algoritiq/keepalive/events"
        const val REQUEST_NOTIFICATIONS = 4101

        private var pendingNotificationResult: MethodChannel.Result? = null

        fun register(engine: FlutterEngine, context: Context) {
            val handler = KeepAliveChannel(context.applicationContext)
            MethodChannel(engine.dartExecutor.binaryMessenger, NAME)
                .setMethodCallHandler(handler)
            EventChannel(engine.dartExecutor.binaryMessenger, EVENTS)
                .setStreamHandler(handler)
        }

        /** Called by the Activity with the answer to the notification dialog. */
        fun onPermissionResult(requestCode: Int, granted: Boolean) {
            if (requestCode != REQUEST_NOTIFICATIONS) return
            pendingNotificationResult?.success(granted)
            pendingNotificationResult = null
        }
    }
}
