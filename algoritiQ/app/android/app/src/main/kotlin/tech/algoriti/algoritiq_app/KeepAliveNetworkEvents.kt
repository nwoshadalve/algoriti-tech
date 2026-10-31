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
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.net.LinkProperties
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import io.flutter.plugin.common.EventChannel

/**
 * Tells Dart to refresh the local name and API addresses while [KeepAliveService]
 * runs. Started with the service (not when Flutter listens): after deep sleep
 * the Wi-Fi stack often comes back without an IP change, and Dart [Timer]s stall
 * in Doze, so a native heartbeat and screen / idle broadcasts are needed too.
 */
object KeepAliveNetworkEvents {
    private const val HEARTBEAT_MS = 30_000L

    private val main = Handler(Looper.getMainLooper())
    private var sink: EventChannel.EventSink? = null
    private var networkCallback: ConnectivityManager.NetworkCallback? = null
    private var screenReceiver: BroadcastReceiver? = null
    private var appContext: Context? = null
    private var onWake: (() -> Unit)? = null
    private var started = false

    private val heartbeat = object : Runnable {
        override fun run() {
            onWake?.invoke()
            ping()
            main.postDelayed(this, HEARTBEAT_MS)
        }
    }

    fun attachSink(events: EventChannel.EventSink?) {
        sink = events
    }

    /** While the foreground service is up. [onWake] re-checks Wi-Fi / CPU locks. */
    fun start(context: Context, onWake: () -> Unit) {
        if (started) return
        started = true
        appContext = context.applicationContext
        this.onWake = onWake
        registerNetworkCallback()
        registerScreenReceiver()
        main.postDelayed(heartbeat, HEARTBEAT_MS)
    }

    fun stop() {
        if (!started) return
        started = false
        main.removeCallbacks(heartbeat)
        unregisterNetworkCallback()
        unregisterScreenReceiver()
        appContext = null
        onWake = null
    }

    fun ping() {
        main.post { sink?.success(null) }
    }

    private fun registerNetworkCallback() {
        val context = appContext ?: return
        val manager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val callback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) = ping()

            override fun onLost(network: Network) = ping()

            override fun onLinkPropertiesChanged(
                network: Network,
                linkProperties: LinkProperties,
            ) = ping()
        }
        networkCallback = callback
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            manager.registerDefaultNetworkCallback(callback)
        } else {
            val request = NetworkRequest.Builder()
                .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
                .build()
            manager.registerNetworkCallback(request, callback)
        }
    }

    private fun unregisterNetworkCallback() {
        val context = appContext ?: return
        val manager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        networkCallback?.let { runCatching { manager.unregisterNetworkCallback(it) } }
        networkCallback = null
    }

    private fun registerScreenReceiver() {
        val context = appContext ?: return
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(ctx: Context?, intent: Intent?) {
                when (intent?.action) {
                    Intent.ACTION_SCREEN_ON -> {
                        onWake?.invoke()
                        ping()
                    }
                    PowerManager.ACTION_DEVICE_IDLE_MODE_CHANGED -> {
                        val power = ctx?.getSystemService(Context.POWER_SERVICE) as? PowerManager
                        if (power != null && !power.isDeviceIdleMode) {
                            onWake?.invoke()
                            ping()
                        }
                    }
                }
            }
        }
        screenReceiver = receiver
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_ON)
            addAction(PowerManager.ACTION_DEVICE_IDLE_MODE_CHANGED)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            context.registerReceiver(receiver, filter)
        }
    }

    private fun unregisterScreenReceiver() {
        val context = appContext ?: return
        screenReceiver?.let { runCatching { context.unregisterReceiver(it) } }
        screenReceiver = null
    }
}
