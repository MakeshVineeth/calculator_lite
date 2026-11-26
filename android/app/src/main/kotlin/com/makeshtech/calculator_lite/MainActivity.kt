package com.makeshtech.calculator_lite

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.core.view.WindowCompat
import com.google.android.play.core.review.ReviewManagerFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.FileInputStream
import java.io.FileOutputStream
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val channelName = "kotlin.flutter.dev"
    private val createFileRequestCode = 6
    private val mainHandler = Handler(Looper.getMainLooper())
    private val ioExecutor: ExecutorService = Executors.newSingleThreadExecutor()

    private var methodChannel: MethodChannel? = null
    private var methodResult: MethodChannel.Result? = null
    private var filePath: String? = null
    private var fileName: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "sendToBackground" -> {
                    result.success(null)
                    finishAndRemoveTask()
                }
                "requestReview" -> {
                    val manager = ReviewManagerFactory.create(applicationContext)
                    val request = manager.requestReviewFlow()
                    request.addOnCompleteListener { task ->
                        if (isFinishing || isDestroyed) {
                            result.success(false)
                            return@addOnCompleteListener
                        }
                        if (task.isSuccessful) {
                            val reviewInfo = task.result
                            manager.launchReviewFlow(this, reviewInfo).addOnCompleteListener {
                                result.success(true)
                            }
                        } else {
                            result.success(false)
                        }
                    }
                }
                "createFile" -> {
                    val requestedPath = call.argument<String>("path")
                    val requestedName = call.argument<String>("fileName")
                    if (methodResult != null ||
                        requestedName.isNullOrBlank() ||
                        requestedPath.isNullOrBlank()
                    ) {
                        result.success(null)
                        return@setMethodCallHandler
                    }

                    methodResult = result
                    filePath = requestedPath
                    fileName = requestedName

                    val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                        addCategory(Intent.CATEGORY_OPENABLE)
                        type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                        putExtra(Intent.EXTRA_TITLE, "$requestedName.xlsx")
                    }

                    try {
                        @Suppress("DEPRECATION")
                        startActivityForResult(intent, createFileRequestCode)
                    } catch (_: Exception) {
                        clearPendingFileState()
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }
        methodChannel = channel
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onDestroy() {
        clearPendingFileState()
        mainHandler.removeCallbacksAndMessages(null)
        ioExecutor.shutdown()
        super.onDestroy()
    }

    private fun clearPendingFileState() {
        methodResult = null
        filePath = null
        fileName = null
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != createFileRequestCode) {
            @Suppress("DEPRECATION")
            super.onActivityResult(requestCode, resultCode, data)
            return
        }

        val pendingResult = methodResult
        val pathStr = filePath
        clearPendingFileState()

        if (resultCode != Activity.RESULT_OK || Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            pendingResult?.success(null)
            return
        }

        val uri = data?.data
        if (uri == null || pathStr.isNullOrBlank()) {
            pendingResult?.success(null)
            return
        }

        ioExecutor.execute {
            var success = false
            try {
                contentResolver.openFileDescriptor(uri, "w")?.use { pfd ->
                    FileInputStream(pathStr).use { input ->
                        FileOutputStream(pfd.fileDescriptor).use { output ->
                            input.copyTo(output)
                        }
                    }
                }
                success = true
            } catch (_: Exception) {
                success = false
            }
            mainHandler.post {
                pendingResult?.success(if (success) "success" else null)
            }
        }
    }
}
