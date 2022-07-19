package com.deskangel.dashare

import android.content.Context
import android.net.Uri
import android.util.Log
import fi.iki.elonen.NanoHTTPD
import java.io.FileNotFoundException

/**
 * Created by William Hsueh(williamx@deskangel.com) on 5/8/20.
 *
 * @param uri: the file which is sharing
 * @param fileName: a fake name as id to match the http url
 */
class FileServer( var context: Context, var uri: Uri, var fileName: String, host: String?, port: Int) : NanoHTTPD(host, port) {

    override fun serve(session: IHTTPSession?): Response {
        Log.d("dafileshare", "request uri: ${session?.uri}, file name: $fileName")

        if (session?.uri == "/$fileName") {
            var fileSize: Long = -1L

            try {
                val fileDesc = context.contentResolver.openFileDescriptor(uri, "r")
                    if (fileDesc != null) {
                        fileSize = fileDesc.statSize
                        fileDesc.close()
                    }
            } catch (e: FileNotFoundException) {
                fileSize = -1L
            }

            return when (val file = context.contentResolver.openInputStream(uri)) {
                null -> {
                    newFixedLengthResponse(Response.Status.NOT_FOUND, MIME_PLAINTEXT, "The file could not be found!")
                }

                else -> {
                    if (fileSize == -1L) {
                        newChunkedResponse(Response.Status.OK, "application/octet-stream", file)
                    } else {
                        newFixedLengthResponse(Response.Status.OK, "application/octet-stream", file, fileSize)
                    }

                }
            }

        }

        return newFixedLengthResponse(Response.Status.NOT_FOUND, MIME_PLAINTEXT, "Url not found!")
    }
}
