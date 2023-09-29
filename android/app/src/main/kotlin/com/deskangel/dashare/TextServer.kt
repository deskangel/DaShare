import android.util.Log
import fi.iki.elonen.NanoHTTPD

class TextServer(private var shortName: String, private var sharedText: String, host: String?, port: Int) : NanoHTTPD(host, port) {
    override fun serve(session: IHTTPSession?): Response {
        Log.d("dafileshare", "shared text")

        if (session?.uri == "/$shortName") {
            return serverText()
        }

        return newFixedLengthResponse(Response.Status.NOT_FOUND, MIME_PLAINTEXT, "Url not found!")
    }

    private fun serverText(): Response {
        val response = newFixedLengthResponse(Response.Status.OK, "text/html", sharedText)
        response.addHeader("Content-Disposition", "inline")

        return response
    }

}
