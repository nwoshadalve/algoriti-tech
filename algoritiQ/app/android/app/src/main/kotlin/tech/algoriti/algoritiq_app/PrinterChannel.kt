/*
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
package tech.algoriti.algoritiq_app

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothClass
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothSocket
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.util.UUID
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.TimeUnit

/**
 * The receptionist's Bluetooth printer: pairing, one connection that stays up,
 * a status reading, and a test page. Classic Bluetooth (SPP) with raw ESC/POS,
 * no vendor SDK. Flutter side: `PrinterGateway`.
 *
 * This class only moves bytes and reports the link. When to connect, when to
 * retry and what to show are decided in Dart.
 *
 * All socket work runs on one background thread, so commands never interleave
 * on the wire. Results go back on the main thread. Permission and pairing
 * dialogs are Android's own; nothing is done silently.
 */
class PrinterChannel(private val context: Context) :
    MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val main = Handler(Looper.getMainLooper())
    private val io: ExecutorService = Executors.newSingleThreadExecutor { r ->
        Thread(r, "printer-io").apply { isDaemon = true }
    }

    private var sink: EventChannel.EventSink? = null

    // Touched only on [io], except [socket] which the reader and receivers read.
    @Volatile private var socket: BluetoothSocket? = null
    @Volatile private var connectedAddress: String? = null
    private var out: OutputStream? = null
    private val received = LinkedBlockingQueue<Int>()

    private var scanReceiver: BroadcastReceiver? = null

    init {
        // Bluetooth switched on or off, or the printer walked away.
        val filter = IntentFilter().apply {
            addAction(BluetoothAdapter.ACTION_STATE_CHANGED)
            addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED)
        }
        context.registerReceiver(object : BroadcastReceiver() {
            override fun onReceive(c: Context, intent: Intent) {
                when (intent.action) {
                    BluetoothAdapter.ACTION_STATE_CHANGED -> {
                        val state = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, -1)
                        if (state == BluetoothAdapter.STATE_OFF) {
                            io.execute { closeSocket() }
                            emit(mapOf("type" to "access", "access" to "off"))
                        } else if (state == BluetoothAdapter.STATE_ON) {
                            emit(mapOf("type" to "access", "access" to access()))
                        }
                    }
                    BluetoothDevice.ACTION_ACL_DISCONNECTED -> {
                        val device = deviceExtra(intent) ?: return
                        if (device.address == connectedAddress) io.execute { dropLink() }
                    }
                }
            }
        }, filter)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "access" -> result.success(access())
            "requestAccess" -> requestAccess(result)
            "requestEnable" -> requestEnable(result)
            "paired" -> result.success(paired())
            "startScan" -> startScan(result)
            "stopScan" -> {
                stopScan()
                result.success(null)
            }
            "pair" -> background(result) { pair(call.argument<String>("address")) }
            "connect" -> background(result) { connect(call.argument<String>("address")) }
            "disconnect" -> background(result) {
                closeSocket()
                null
            }
            "print" -> background(result) { print(call.argument<ByteArray>("bytes")) }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    private fun emit(event: Map<String, Any?>) {
        main.post { sink?.success(event) }
    }

    private fun background(result: MethodChannel.Result, work: () -> Any?) {
        io.execute {
            val value = try {
                work()
            } catch (e: SecurityException) {
                Log.w(TAG, "Bluetooth permission missing")
                "denied"
            } catch (e: Exception) {
                Log.w(TAG, "Printer call failed: ${e.javaClass.simpleName}")
                "failed"
            }
            main.post { result.success(value) }
        }
    }

    // ---------------------------------------------------------------- access

    private fun adapter(): BluetoothAdapter? =
        (context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager)?.adapter

    private fun has(permission: String) =
        context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED

    private fun hasPermissions(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
            (has(Manifest.permission.BLUETOOTH_CONNECT) && has(Manifest.permission.BLUETOOTH_SCAN))

    /** `ready`, `off`, `denied` or `missing`. */
    private fun access(): String {
        if (!context.packageManager.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH)) return "missing"
        val adapter = adapter() ?: return "missing"
        if (!hasPermissions()) return "denied"
        return try {
            if (adapter.isEnabled) "ready" else "off"
        } catch (_: SecurityException) {
            "denied"
        }
    }

    private fun requestAccess(result: MethodChannel.Result) {
        if (access() != "denied") {
            result.success(access())
            return
        }
        val activity: Activity? = EngineHolder.activity
        if (activity == null) {
            result.success("denied")
            return
        }
        pendingPermission?.success("denied")
        pendingPermission = result
        activity.requestPermissions(
            arrayOf(Manifest.permission.BLUETOOTH_CONNECT, Manifest.permission.BLUETOOTH_SCAN),
            REQUEST_PRINTER_PERMISSIONS,
        )
    }

    @SuppressLint("MissingPermission")
    private fun requestEnable(result: MethodChannel.Result) {
        val activity: Activity? = EngineHolder.activity
        try {
            if (activity != null) {
                activity.startActivityForResult(
                    Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE),
                    REQUEST_ENABLE_BLUETOOTH,
                )
            } else {
                context.startActivity(
                    Intent(android.provider.Settings.ACTION_BLUETOOTH_SETTINGS)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                )
            }
        } catch (_: RuntimeException) {
            Log.w(TAG, "Could not open the Bluetooth dialog")
        }
        result.success(null)
    }

    // ------------------------------------------------------- paired / scanning

    @SuppressLint("MissingPermission")
    private fun paired(): List<Map<String, String>> {
        if (access() != "ready") return emptyList()
        val bonded = adapter()?.bondedDevices.orEmpty()
        // Printers first; if the tablet does not class any as a printer (many
        // small models do not), list everything paired so none is hidden.
        val printers = bonded.filter { isPrinterClass(it) }
        return (printers.ifEmpty { bonded.toList() }).map { describe(it) }
    }

    @SuppressLint("MissingPermission")
    private fun isPrinterClass(device: BluetoothDevice): Boolean =
        device.bluetoothClass?.majorDeviceClass == BluetoothClass.Device.Major.IMAGING

    @SuppressLint("MissingPermission")
    private fun describe(device: BluetoothDevice) =
        mapOf("name" to (device.name ?: ""), "address" to device.address)

    @SuppressLint("MissingPermission")
    private fun startScan(result: MethodChannel.Result) {
        val adapter = adapter()
        if (adapter == null || access() != "ready") {
            result.success(null)
            return
        }
        stopScan()
        // Cancelling an earlier scan sends its "finished" broadcast late; ignore
        // any finish that comes before this scan's own "started".
        var started = false
        val receiver = object : BroadcastReceiver() {
            @SuppressLint("MissingPermission")
            override fun onReceive(c: Context, intent: Intent) {
                when (intent.action) {
                    BluetoothAdapter.ACTION_DISCOVERY_STARTED -> started = true
                    BluetoothDevice.ACTION_FOUND -> {
                        val device = deviceExtra(intent) ?: return
                        // A device that does not announce a name cannot be told apart.
                        if (device.name.isNullOrBlank()) return
                        emit(mapOf("type" to "found") + describe(device))
                    }
                    BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                        if (!started) return
                        stopScan()
                        emit(mapOf("type" to "scanEnded"))
                    }
                }
            }
        }
        scanReceiver = receiver
        context.registerReceiver(
            receiver,
            IntentFilter().apply {
                addAction(BluetoothDevice.ACTION_FOUND)
                addAction(BluetoothAdapter.ACTION_DISCOVERY_STARTED)
                addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
            },
        )
        if (!adapter.startDiscovery()) {
            stopScan()
            emit(mapOf("type" to "scanEnded"))
        }
        result.success(null)
    }

    @SuppressLint("MissingPermission")
    private fun stopScan() {
        scanReceiver?.let {
            try {
                context.unregisterReceiver(it)
            } catch (_: IllegalArgumentException) {
            }
        }
        scanReceiver = null
        try {
            val adapter = adapter()
            if (adapter?.isDiscovering == true) adapter.cancelDiscovery()
        } catch (_: SecurityException) {
        }
    }

    @Suppress("DEPRECATION")
    private fun deviceExtra(intent: Intent): BluetoothDevice? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
        } else {
            intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
        }

    // ---------------------------------------------------------------- pairing

    /** `paired`, `rejected` (cancelled or wrong code) or `failed`. */
    @SuppressLint("MissingPermission")
    private fun pair(address: String?): String {
        val device = remoteDevice(address) ?: return "failed"
        if (device.bondState == BluetoothDevice.BOND_BONDED) return "paired"
        stopScan()

        val done = LinkedBlockingQueue<Int>()
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(c: Context, intent: Intent) {
                val changed = deviceExtra(intent) ?: return
                if (changed.address != device.address) return
                val state = intent.getIntExtra(BluetoothDevice.EXTRA_BOND_STATE, BluetoothDevice.ERROR)
                if (state == BluetoothDevice.BOND_BONDED || state == BluetoothDevice.BOND_NONE) {
                    done.offer(state)
                }
            }
        }
        context.registerReceiver(receiver, IntentFilter(BluetoothDevice.ACTION_BOND_STATE_CHANGED))
        try {
            if (!device.createBond()) return "failed"
            // The person types the code in Android's dialog; give them time.
            val state = done.poll(PAIR_TIMEOUT_SECONDS, TimeUnit.SECONDS)
            return when (state) {
                BluetoothDevice.BOND_BONDED -> "paired"
                BluetoothDevice.BOND_NONE -> "rejected"
                else -> "failed"
            }
        } finally {
            context.unregisterReceiver(receiver)
        }
    }

    @SuppressLint("MissingPermission")
    private fun remoteDevice(address: String?): BluetoothDevice? {
        if (address == null || !BluetoothAdapter.checkBluetoothAddress(address)) return null
        return adapter()?.getRemoteDevice(address)
    }

    // ------------------------------------------------------------- connecting

    /** `connected`, `off`, `denied` or `failed`. Stays connected until closed. */
    @SuppressLint("MissingPermission")
    private fun connect(address: String?): String {
        when (access()) {
            "off" -> return "off"
            "denied" -> return "denied"
            "missing" -> return "failed"
        }
        val device = remoteDevice(address) ?: return "failed"
        if (socket?.isConnected == true && connectedAddress == device.address) return "connected"
        closeSocket()
        stopScan()

        var candidate: BluetoothSocket? = null
        try {
            candidate = openSocket(device)
        } catch (e: IOException) {
            Log.i(TAG, "Printer not reachable: ${e.message}")
            return "failed"
        }
        socket = candidate
        connectedAddress = device.address
        out = candidate.outputStream
        received.clear()
        startReader(candidate.inputStream, candidate)
        Log.i(TAG, "Printer connected")
        return "connected"
    }

    /** The standard SPP service first; some cheap firmwares only answer on channel 1. */
    @SuppressLint("MissingPermission")
    private fun openSocket(device: BluetoothDevice): BluetoothSocket {
        try {
            val s = device.createRfcommSocketToServiceRecord(SPP_UUID)
            s.connect()
            return s
        } catch (first: IOException) {
            Log.i(TAG, "SPP service failed, trying channel 1")
            try {
                val method = device.javaClass.getMethod("createRfcommSocket", Int::class.javaPrimitiveType)
                val s = method.invoke(device, 1) as BluetoothSocket
                s.connect()
                return s
            } catch (_: Exception) {
                throw first
            }
        }
    }

    /** Reads whatever the printer sends; when the read fails the link is gone. */
    private fun startReader(input: InputStream, owner: BluetoothSocket) {
        Thread({
            val buffer = ByteArray(64)
            try {
                while (true) {
                    val n = input.read(buffer)
                    if (n < 0) break
                    for (i in 0 until n) received.offer(buffer[i].toInt() and 0xFF)
                }
            } catch (_: IOException) {
            }
            io.execute { if (socket === owner) dropLink() }
        }, "printer-reader").apply { isDaemon = true }.start()
    }

    /** The printer went away: close and tell Dart so it reconnects. */
    private fun dropLink() {
        if (socket == null) return
        Log.i(TAG, "Printer link lost")
        closeSocket()
        emit(mapOf("type" to "link", "connected" to false))
    }

    private fun closeSocket() {
        val s = socket
        socket = null
        connectedAddress = null
        out = null
        try {
            s?.close()
        } catch (_: IOException) {
        }
    }

    // ----------------------------------------------------------------- status

    private fun write(bytes: ByteArray): Boolean {
        val stream = out ?: return false
        return try {
            stream.write(bytes)
            stream.flush()
            true
        } catch (_: IOException) {
            dropLink()
            false
        }
    }

    /** Sends [command] and waits for [expected] reply bytes; null if none came. */
    private fun ask(command: ByteArray, expected: Int = 1): IntArray? {
        received.clear()
        if (!write(command)) return null
        val reply = IntArray(expected)
        for (i in 0 until expected) {
            reply[i] = received.poll(REPLY_TIMEOUT_MS, TimeUnit.MILLISECONDS) ?: return null
        }
        return reply
    }

    // ------------------------------------------------------------------ print

    /**
     * `printed`, `not_connected` or `failed`. [job] is a finished ESC/POS job:
     * Bengali is drawn by Flutter as an image, the printer has no Bengali font.
     */
    private fun print(job: ByteArray?): String {
        if (job == null || job.isEmpty()) return "failed"
        if (socket?.isConnected != true) return "not_connected"
        // Cover open or paper end: do not send a job that cannot print.
        val status = ask(DLE_EOT_OFFLINE)
        if (status != null && status[0] and 0x24 != 0) return "failed"
        var offset = 0
        while (offset < job.size) {
            val end = minOf(offset + CHUNK_BYTES, job.size)
            if (!write(job.copyOfRange(offset, end))) return "not_connected"
            offset = end
        }
        return "printed"
    }

    companion object {
        const val NAME = "tech.algoriti.algoritiq/printer"
        const val EVENTS = "tech.algoriti.algoritiq/printer/events"
        const val REQUEST_PRINTER_PERMISSIONS = 4104
        const val REQUEST_ENABLE_BLUETOOTH = 4103

        private const val TAG = "PrinterChannel"
        private const val PAIR_TIMEOUT_SECONDS = 90L
        private const val REPLY_TIMEOUT_MS = 800L
        private const val CHUNK_BYTES = 1024
        private val SPP_UUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")


        /** DLE EOT 2: offline cause (cover, paper end, error). */
        private val DLE_EOT_OFFLINE = byteArrayOf(0x10, 0x04, 0x02)

        private var pendingPermission: MethodChannel.Result? = null
        private var instance: PrinterChannel? = null

        fun register(engine: FlutterEngine, context: Context) {
            val channel = PrinterChannel(context.applicationContext)
            instance = channel
            MethodChannel(engine.dartExecutor.binaryMessenger, NAME).setMethodCallHandler(channel)
            EventChannel(engine.dartExecutor.binaryMessenger, EVENTS).setStreamHandler(channel)
        }

        fun onPermissionResult(requestCode: Int, granted: Boolean) {
            if (requestCode != REQUEST_PRINTER_PERMISSIONS) return
            val result = pendingPermission ?: return
            pendingPermission = null
            result.success(instance?.access() ?: if (granted) "ready" else "denied")
            if (granted) instance?.emit(mapOf("type" to "access", "access" to instance?.access()))
        }
    }
}
