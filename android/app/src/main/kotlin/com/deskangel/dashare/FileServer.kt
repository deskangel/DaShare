package com.deskangel.dashare

import android.content.Context
import android.net.Uri
import android.util.Log
import fi.iki.elonen.NanoHTTPD
import java.io.FileInputStream

/**
 * Created by William Hsueh(williamx@deskangel.com) on 5/8/20.
 */
class FileServer( var context: Context, var uri: Uri, var fileName: String) : NanoHTTPD(0) {

    override fun serve(session: IHTTPSession?): Response {
        Log.d("dafileshare", "request uri: ${session?.uri}, file name: $fileName")

        if (session?.uri == "/$fileName") {
            val fileDesc = context.contentResolver.openFileDescriptor(uri, "r", null)
            val file = FileInputStream(fileDesc!!.fileDescriptor)

            val size: Long = file.channel.size()
            return newFixedLengthResponse(Response.Status.OK, "application/octet-stream", file, size)
        }

        return newFixedLengthResponse(Response.Status.NOT_FOUND, MIME_PLAINTEXT, "File not found!")
    }
}
