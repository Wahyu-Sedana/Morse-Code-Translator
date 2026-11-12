package com.codebasedigital.morsecode

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var torch: TorchController? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val controller = TorchController(applicationContext)
        torch = controller
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "morse/torch").setMethodCallHandler { call, result ->
            when (call.method) {
                "isAvailable" -> result.success(controller.isAvailable())
                "playPattern" -> {
                    val pattern = call.argument<List<Number>>("pattern").orEmpty().map { it.toLong() }
                    controller.play(pattern)
                    result.success(null)
                }
                "stop" -> {
                    controller.stop()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onPause() {
        // Never leave the flashlight on when the app goes to the background.
        torch?.stop()
        super.onPause()
    }

    override fun onDestroy() {
        torch?.stop()
        super.onDestroy()
    }
}
