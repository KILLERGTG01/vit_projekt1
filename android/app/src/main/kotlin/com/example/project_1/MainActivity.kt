package com.example.project_1

import android.content.ContentResolver
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.InputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.project_1/file_utils"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getImageFromUri" -> {
                    val uriString = call.argument<String>("uri")
                    if (uriString != null) {
                        try {
                            val imageBytes = getImageBytesFromUri(uriString)
                            result.success(imageBytes)
                        } catch (e: Exception) {
                            result.error("ERROR", "Failed to read image from URI: ${e.message}", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "URI is null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getImageBytesFromUri(uriString: String): ByteArray? {
        return try {
            val uri = Uri.parse(uriString)
            val contentResolver: ContentResolver = contentResolver
            val inputStream: InputStream? = contentResolver.openInputStream(uri)
            
            inputStream?.use { stream ->
                val buffer = ByteArrayOutputStream()
                val data = ByteArray(1024)
                var nRead: Int
                
                while (stream.read(data, 0, data.size).also { nRead = it } != -1) {
                    buffer.write(data, 0, nRead)
                }
                
                buffer.toByteArray()
            }
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
}