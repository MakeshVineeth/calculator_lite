package com.makeshtech.calculator_lite

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.FileOutputStream
import java.nio.file.Files
import java.nio.file.Paths

class MainActivity : FlutterActivity() {
    private val channel = "kotlin.flutter.dev"
    private val createFileRequestCode = 6
    private var methodResult: MethodChannel.Result? = null
    private var filePath: String? = null
    private var fileName: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendToBackground" -> {
                    finishAndRemoveTask()
                    Handler(Looper.getMainLooper()).postDelayed({
                        kotlin.system.exitProcess(0)
                    }, 1000)
                }
                "createFile" -> {
                    methodResult = result
                    filePath = call.argument("path")
                    fileName = call.argument("fileName")

                    if (fileName.isNullOrBlank()) {
                        result.success(null)
                        return@setMethodCallHandler
                    }

                    val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                        addCategory(Intent.CATEGORY_OPENABLE)
                        type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                        putExtra(Intent.EXTRA_TITLE, "$fileName.xlsx")
                    }

                    @Suppress("DEPRECATION")
                    startActivityForResult(intent, createFileRequestCode)
                }
                else -> result.notImplemented()
            }
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != createFileRequestCode) {
            @Suppress("DEPRECATION")
            super.onActivityResult(requestCode, resultCode, data)
            return
        }

        if (resultCode == Activity.RESULT_OK && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                data?.data?.also { uri ->
                    val pathStr = filePath
                    if (pathStr != null) {
                        val pathObj = Paths.get(pathStr)
                        val fileContent = Files.readAllBytes(pathObj)

                        contentResolver.openFileDescriptor(uri, "w")?.use { pfd ->
                            FileOutputStream(pfd.fileDescriptor).use { output ->
                                output.write(fileContent)
                            }
                        }
                        methodResult?.success("success")
                    } else {
                        methodResult?.success(null)
                    }
                } ?: run {
                    methodResult?.success(null)
                }
            } catch (ex: Exception) {
                methodResult?.success(null)
            }
        } else {
            methodResult?.success(null)
        }
        methodResult = null
    }
}
