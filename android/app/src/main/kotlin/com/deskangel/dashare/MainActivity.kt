package com.deskangel.dashare

import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    companion object {
        const val CHANNEL = "com.deskangel.dashare/fileserver"
    }

    private lateinit var server: FileServer

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "startFileService" -> {
                    if (this.intent.action == Intent.ACTION_SEND) {
                        val uri = this.intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
                        if (uri != null) {
                            val fileName = call.argument<String>("fileName")!!
                            val host = call.argument<String>("host")
                            val port = call.argument<Int>("port") ?: 0

                            server = FileServer(this, uri, fileName, host, port)
                            server.start()

                            result.success(server.hostname + ":" + server.listeningPort)
                        } else {
                            result.error("2", "not find the sharing file", null)
                        }
                    }
                }
                "stopFileService" -> {
                    if (this::server.isInitialized) {

                        server.closeAllConnections()

                        result.success("success")
                    }

                }
                "retrieveFileInfo" -> {
                    if (this.intent.action == Intent.ACTION_SEND) {

                        val uri = this.intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)

                        if (uri == null) {
                            result.error("2", "not find the sharing file", null)
                            return@setMethodCallHandler
                        }

                        val cursor = contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE),
                                null, null, null)
                        cursor?.moveToFirst()
                        val nameIndex = cursor?.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                        val sizeIndex = cursor?.getColumnIndex(OpenableColumns.SIZE)
                        cursor?.moveToFirst()

                        val fileName = if (nameIndex == -1 || nameIndex == null) "noname" else cursor.getString(nameIndex)
                        val fileSize = if (sizeIndex == -1 || sizeIndex == null) null else cursor.getLong(sizeIndex)

                        cursor?.close()

                        val info = hashMapOf(
                                "fileName" to fileName,
                                "fileSize" to fileSize
                        )



                        result.success(info)
                    } else {
                        result.error("1", "non sharing action", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

    }

}
