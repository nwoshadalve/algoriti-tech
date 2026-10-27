package tech.algoriti.algoritiq_app

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Lets the Dart side say "the first real screen is drawn", so the launch
 * screen can be dismissed without a blank gap. Flutter side: `NativeSplash`.
 */
class SplashChannel(private val onRelease: () -> Unit) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "release" -> {
                onRelease()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        const val NAME = "tech.algoriti.algoritiq/splash"

        fun register(engine: FlutterEngine, onRelease: () -> Unit) {
            MethodChannel(engine.dartExecutor.binaryMessenger, NAME)
                .setMethodCallHandler(SplashChannel(onRelease))
        }
    }
}
