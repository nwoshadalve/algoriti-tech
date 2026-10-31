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
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Process
import android.os.StatFs
import android.os.SystemClock
import android.provider.Settings
import android.app.ActivityManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * What the admin monitoring page shows about the tablet itself: memory,
 * storage, Bluetooth, how long it has been up, and how busy this app is.
 * Flutter side: `SystemHealthGateway`.
 *
 * CPU is the app's own share of the processor: since Android 8 apps may not
 * read the system-wide figures.
 *
 * `requestBluetoothEnable` opens Android's own dialog or settings on the
 * tablet screen; the person confirms there (never silent).
 */
class SystemHealthChannel(private val context: Context) : MethodChannel.MethodCallHandler {

    private var lastCpuMs = Process.getElapsedCpuTime()
    private var lastWallMs = SystemClock.elapsedRealtime()
    private var lastCpuPercent = 0.0

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "snapshot" -> result.success(snapshot())
            "requestBluetoothConnect" -> requestBluetoothConnect(result)
            "requestBluetoothEnable" -> requestBluetoothEnable(result)
            else -> result.notImplemented()
        }
    }

    private fun snapshot(): Map<String, Any?> {
        val now = SystemClock.elapsedRealtime()
        val memory = ActivityManager.MemoryInfo().also {
            (context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager).getMemoryInfo(it)
        }
        val disk = StatFs(context.filesDir.path)
        return mapOf(
            "cpuPercent" to cpuPercent(now),
            "cpuCores" to Runtime.getRuntime().availableProcessors(),
            "ramTotalBytes" to memory.totalMem,
            "ramAvailableBytes" to memory.availMem,
            "ramLow" to memory.lowMemory,
            "storageTotalBytes" to disk.totalBytes,
            "storageAvailableBytes" to disk.availableBytes,
            "bluetooth" to bluetooth(),
            "deviceUptimeMs" to now,
            "androidServiceUptimeMs" to KeepAliveService.startedAt?.let { now - it },
        )
    }

    /** The app's share of all cores since the last call (0-100). */
    private fun cpuPercent(now: Long): Double {
        val wall = now - lastWallMs
        if (wall < MIN_WINDOW_MS) return lastCpuPercent
        val cpu = Process.getElapsedCpuTime()
        val cores = Runtime.getRuntime().availableProcessors().coerceAtLeast(1)
        lastCpuPercent = ((cpu - lastCpuMs).toDouble() / wall / cores * 100).coerceIn(0.0, 100.0)
        lastCpuMs = cpu
        lastWallMs = now
        return lastCpuPercent
    }

    /** `on`, `off`, `missing` (no Bluetooth hardware) or `denied` (no permission). */
    private fun bluetooth(): String {
        if (!hasBluetoothHardware()) return "missing"
        val adapter = bluetoothAdapter() ?: return "missing"
        return try {
            if (adapter.isEnabled) "on" else "off"
        } catch (_: SecurityException) {
            "denied"
        }
    }

    private fun hasBluetoothHardware(): Boolean =
        context.packageManager.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH)

    private fun bluetoothAdapter(): BluetoothAdapter? =
        (context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager)?.adapter

    private fun hasConnectPermission(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
            context.checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) ==
            PackageManager.PERMISSION_GRANTED

    private fun requestBluetoothConnect(result: MethodChannel.Result) {
        if (!hasBluetoothHardware() || hasConnectPermission()) {
            result.success(mapOf("granted" to true))
            return
        }
        val activity = EngineHolder.activity
        if (activity == null) {
            result.success(mapOf("granted" to false))
            return
        }
        pendingConnectResult?.error("SUPERSEDED", null, null)
        pendingConnectResult = result
        activity.requestPermissions(
            arrayOf(Manifest.permission.BLUETOOTH_CONNECT),
            REQUEST_BLUETOOTH_CONNECT,
        )
    }

    private fun requestBluetoothEnable(result: MethodChannel.Result) {
        if (!hasBluetoothHardware()) {
            result.success(mapOf("outcome" to "missing"))
            return
        }
        if (!hasConnectPermission()) {
            val activity = EngineHolder.activity
            if (activity == null) {
                result.success(mapOf("outcome" to "need_app_open"))
                return
            }
            pendingEnableResult?.error("SUPERSEDED", null, null)
            pendingEnableResult = result
            activity.requestPermissions(
                arrayOf(Manifest.permission.BLUETOOTH_CONNECT),
                REQUEST_BLUETOOTH_CONNECT,
            )
            return
        }
        continueBluetoothEnable(result)
    }

    private fun continueBluetoothEnable(result: MethodChannel.Result) {
        val adapter = bluetoothAdapter()
        if (adapter == null) {
            result.success(mapOf("outcome" to "missing"))
            return
        }
        try {
            if (adapter.isEnabled) {
                result.success(mapOf("outcome" to "already_on"))
                return
            }
        } catch (_: SecurityException) {
            result.success(mapOf("outcome" to "denied"))
            return
        }

        val activity = EngineHolder.activity
        if (activity != null) {
            try {
                activity.startActivityForResult(
                    Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE),
                    REQUEST_ENABLE_BLUETOOTH,
                )
                result.success(mapOf("outcome" to "dialog_shown"))
                return
            } catch (_: RuntimeException) {
                // Fall through to settings.
            }
        }

        val settings = Intent(Settings.ACTION_BLUETOOTH_SETTINGS)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (launch(settings)) {
            result.success(mapOf("outcome" to "settings_opened"))
        } else {
            result.error("CANNOT_OPEN", "Bluetooth settings are not available.", null)
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
        const val NAME = "tech.algoriti.algoritiq/systemhealth"
        private const val MIN_WINDOW_MS = 1000L
        const val REQUEST_BLUETOOTH_CONNECT = 4102
        const val REQUEST_ENABLE_BLUETOOTH = 4103

        private var pendingConnectResult: MethodChannel.Result? = null
        private var pendingEnableResult: MethodChannel.Result? = null
        private var handler: SystemHealthChannel? = null

        fun register(engine: FlutterEngine, context: Context) {
            handler = SystemHealthChannel(context.applicationContext)
            MethodChannel(engine.dartExecutor.binaryMessenger, NAME)
                .setMethodCallHandler(handler)
        }

        fun onPermissionResult(requestCode: Int, granted: Boolean) {
            if (requestCode != REQUEST_BLUETOOTH_CONNECT) return
            pendingConnectResult?.let { connect ->
                pendingConnectResult = null
                connect.success(mapOf("granted" to granted))
                return
            }
            val result = pendingEnableResult ?: return
            pendingEnableResult = null
            if (!granted) {
                result.success(mapOf("outcome" to "denied"))
                return
            }
            handler?.continueBluetoothEnable(result)
        }
    }
}
