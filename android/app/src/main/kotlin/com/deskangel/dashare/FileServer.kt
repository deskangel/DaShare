package com.deskangel.dashare

import android.content.Context
import android.net.Uri
import android.util.Log
import fi.iki.elonen.NanoHTTPD

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
            val fileDesc = context.contentResolver.openFileDescriptor(uri, "r")
                ?: return newFixedLengthResponse(Response.Status.NOT_FOUND, MIME_PLAINTEXT, "File not found!")

            return when (val file = context.contentResolver.openInputStream(uri)) {
                null -> {
                    newFixedLengthResponse(Response.Status.NOT_FOUND, MIME_PLAINTEXT, "File not found!")
                }

                else -> newFixedLengthResponse(Response.Status.OK, "application/octet-stream", file, fileDesc.statSize)
            }

        }

        return newFixedLengthResponse(Response.Status.NOT_FOUND, MIME_PLAINTEXT, "File not found!")
    }
}
