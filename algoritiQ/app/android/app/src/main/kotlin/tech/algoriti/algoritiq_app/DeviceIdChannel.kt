package tech.algoriti.algoritiq_app

import android.content.Context
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Read-only access to the device identity used to bind a license.
 *
 * One call, no state: a plain MethodChannel is enough here (no Pigeon).
 * Flutter side: `AndroidDeviceIdSource`.
 */
class DeviceIdChannel(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "androidId" -> {
                val id = Settings.Secure.getString(
                    context.contentResolver,
                    Settings.Secure.ANDROID_ID,
                )
                if (id.isNullOrEmpty()) {
                    result.error("UNAVAILABLE", "ANDROID_ID is not available", null)
                } else {
                    result.success(id)
                }
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        const val NAME = "tech.algoriti.algoritiq/device"

        fun register(engine: FlutterEngine, context: Context) {
            MethodChannel(engine.dartExecutor.binaryMessenger, NAME)
                .setMethodCallHandler(DeviceIdChannel(context))
        }
    }
}
