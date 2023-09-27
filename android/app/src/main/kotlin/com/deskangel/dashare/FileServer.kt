package com.deskangel.dashare

import android.content.Context
import android.net.Uri
import android.text.Html
import android.util.Log
import fi.iki.elonen.NanoHTTPD
import java.io.FileNotFoundException

/**
 * Created by William Hsueh(williamx@deskangel.com) on 5/8/20.
 *
 * @param uri: the file which is sharing
 * @param shortName: a fake name as id to match the http url
 */
class FileServer(private var context: Context, private var uri: Uri, private var shortName: String, private var fileName: String?, host: String?, port: Int) : NanoHTTPD(host, port) {

    override fun serve(session: IHTTPSession?): Response {
        Log.d("dafileshare", "request uri: ${session?.uri}, file name: $fileName")

        if (session?.uri == "/text-share.html") {
            return serverText()
        } else if (session?.uri == "/$shortName") {
            return serverFile()
        }

        return newFixedLengthResponse(Response.Status.NOT_FOUND, MIME_PLAINTEXT, "Url not found!")
    }

    private fun serverText(): Response {
        val htmlCode = "<h1>This is a heading</h1><p>This is a paragraph</p>"

        val escapedHtmlCode = Html.escapeHtml(htmlCode)

        val htmlContent = """
                <html>
                <head>
                    <title>Text Share</title>
                </head>
                <body>
                    $escapedHtmlCode
                </body>
                </html>
            """.trimIndent()

        val response = newFixedLengthResponse(Response.Status.OK, "text/html", htmlContent)
        response.addHeader("Content-Disposition", "inline")

        return response
    }

    private fun serverFile(): Response {
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
                newFixedLengthResponse(
                    Response.Status.NOT_FOUND,
                    MIME_PLAINTEXT,
                    "The file could not be found!"
                )
            }

            else -> {
                val response: Response = if (fileSize == -1L) {
                    newChunkedResponse(Response.Status.OK, "application/octet-stream", file)
                } else {
                    newFixedLengthResponse(
                        Response.Status.OK,
                        "application/octet-stream",
                        file,
                        fileSize
                    )
                }

                response.addHeader(
                    "Content-Disposition",
                    "attachment; filename=\"${fileName ?: shortName}\""
                )

                response
            }
        }
    }
}
