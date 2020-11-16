package com.makeshtech.calculator_lite

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Handler

class MainActivity : FlutterActivity() {
  private val CHANNEL = "android_app_exit"

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
      call, result ->
      if (call.method == "sendToBackground") {
        this.finishAndRemoveTask();
        Handler().postDelayed({
          System.exit(0);
          }, 1000)
      }
    }
  }
}
