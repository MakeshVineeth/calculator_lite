package com.makeshtech.calculator_lite

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Handler
import android.app.Activity
import android.content.Intent
import android.os.Build
import java.io.File
import java.io.FileOutputStream
import java.nio.file.Files
import java.nio.file.Paths

class MainActivity : FlutterActivity() {
  private val CHANNEL = "kotlin.flutter.dev"
  private val CREATE_FILE = 6
  private lateinit var _result: MethodChannel.Result
  var path: String? = ""
  var fileName: String? = ""

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
      else if (call.method == "createFile") {
        _result = result
        path = call.argument("path")
        fileName = call.argument("fileName")

        if (fileName.isNullOrBlank()) {
            _result.success(null)
        }

        val intent =
                Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = "application/xlsx"
                    putExtra(Intent.EXTRA_TITLE, fileName + ".xlsx")
                }

        startActivityForResult(intent, CREATE_FILE)
      }
    }
  }

    override fun onActivityResult(requestCode: Int, result: Int, intent: Intent?) {
      if (requestCode != CREATE_FILE) return super.onActivityResult(requestCode, result, intent)

      if (result == Activity.RESULT_OK && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

          try {
              intent?.data?.also { uri ->
                  var _path = Paths.get(path)
                  var fileContent = Files.readAllBytes(_path)

                  contentResolver.openFileDescriptor(uri, "w")?.use {
                      FileOutputStream(it.fileDescriptor).use { it.write(fileContent) }
                  }

                  _result.success("success")
              }
          } catch (ex: Exception) {
              _result.success(null)
          }
      } else {
          _result.success(null)
      }
  }

  fun File.copyTo(file: File) {
      inputStream().use { input -> file.outputStream().use { output -> input.copyTo(output) } }
  }
}
