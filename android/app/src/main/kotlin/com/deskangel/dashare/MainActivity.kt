package com.deskangel.dashare

import android.annotation.TargetApi
import android.content.ContentResolver
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.FileNotFoundException

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
                        val uri = getParcelableExtraUri()
                        if (uri != null) {
                            val shortName = call.argument<String>("shortName")!!
                            val fileName = call.argument<String>("fileName")
                            val host = call.argument<String>("host")
                            val port = call.argument<Int>("port") ?: 0

                            server = FileServer(this, uri, shortName, fileName, host, port)
                            server.start()

                            result.success(server.hostname + ":" + server.listeningPort)
                        } else {
                            result.error("2", "Cannot find the sharing file", null)
                        }
                    } else {
                        result.error("1", "non sharing action", null)
                    }
                }
                "stopFileService" -> {
                    if (this::server.isInitialized) {

                        server.closeAllConnections()

                    }
                    result.success("success")

                }
                "getSharedFileUriScheme" -> {
                    if (this.intent.action == Intent.ACTION_SEND) {
                        val uri = getParcelableExtraUri()
                        if (uri == null) {
                            result.error("2", "Cannot find the sharing file", null)
                        } else if (uri.scheme == null) {
                            result.error("2", "Cannot find the sharing file", null)
                        } else {
                            result.success(uri.scheme)
                        }
                    } else {
                        result.error("1", "non sharing action", null)
                    }
                }
                "retrieveFileInfo" -> {
                    if (this.intent.action == Intent.ACTION_SEND) {

                        val uri = getParcelableExtraUri()

                        if (uri == null) {
                            result.error("2", "Cannot find the sharing file", null)
                            return@setMethodCallHandler
                        }

                        if (uri.scheme == ContentResolver.SCHEME_FILE) {
                            val fileName = uri.lastPathSegment
                            var fileSize = -1L

                            try {
                                val fileDesc =  contentResolver.openFileDescriptor(uri, "r")
                                if (fileDesc != null) {
                                    fileSize = fileDesc.statSize
                                    fileDesc.close()
                                }
                            } catch (e : FileNotFoundException) {
//                                result.error("3", "Failed to retrieve the sharing file information", fileName)
                                val info = hashMapOf(
                                    "fileName" to fileName,
                                    "fileSize" to fileSize,
                                    "code" to "Failed to retrieve the sharing file information"
                                )

                                result.success(info)

                                return@setMethodCallHandler
                            }

                            val info = hashMapOf(
                                "fileName" to fileName,
                                "fileSize" to fileSize
                            )

                            result.success(info)
                        } else {
                            val cursor = contentResolver.query(
                                uri, arrayOf(OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE),
                                null, null, null
                            )
                            cursor?.moveToFirst()
                            val nameIndex = cursor?.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                            val sizeIndex = cursor?.getColumnIndex(OpenableColumns.SIZE)
                            cursor?.moveToFirst()

                            val fileName =
                                if (nameIndex == null || nameIndex == -1) {
                                    "noname"
                                } else {
                                    cursor.getString(nameIndex)
                                }
                            val fileSize =
                                if (sizeIndex == null || sizeIndex == -1) {
                                    -1
                                } else {
                                    cursor.getLong(sizeIndex)
                                }

                            cursor?.close()

                            val info = hashMapOf(
                                "fileName" to fileName,
                                "fileSize" to fileSize
                            )

                            result.success(info)
                        }
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

    private fun getParcelableExtraUri(): Uri? {
        val uri =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                this.intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
            } else {
                @Suppress("DEPRECATION")
                this.intent.getParcelableExtra(Intent.EXTRA_STREAM)
            }
        return uri
    }
}
