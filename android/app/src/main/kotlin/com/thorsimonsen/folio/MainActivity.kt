package com.thorsimonsen.folio

import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.pdf.PdfRenderer
import android.os.Handler
import android.os.Looper
import android.os.ParcelFileDescriptor
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.thorsimonsen.folio/pdf"
    }

    private var pdfRenderer: PdfRenderer? = null
    private var fileDescriptor: ParcelFileDescriptor? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openDocument" -> {
                        val path = call.argument<String>("path")
                        Thread { openDocument(path, result) }.start()
                    }
                    "getPageCount" -> result.success(pdfRenderer?.pageCount ?: 0)
                    "renderPage" -> {
                        val index = call.argument<Int>("index") ?: 0
                        val width = call.argument<Int>("width") ?: 800
                        Thread { renderPage(index, width, result) }.start()
                    }
                    "closeDocument" -> {
                        closeDocument()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun openDocument(path: String?, result: MethodChannel.Result) {
        if (path == null) {
            mainHandler.post { result.error("INVALID_PATH", "Path is null", null) }
            return
        }
        try {
            closeDocument()
            val fd = ParcelFileDescriptor.open(File(path), ParcelFileDescriptor.MODE_READ_ONLY)
            fileDescriptor = fd
            pdfRenderer = PdfRenderer(fd)
            val count = pdfRenderer!!.pageCount
            mainHandler.post { result.success(count) }
        } catch (e: Exception) {
            mainHandler.post { result.error("OPEN_ERROR", e.message, null) }
        }
    }

    private fun renderPage(index: Int, width: Int, result: MethodChannel.Result) {
        val renderer = pdfRenderer
        if (renderer == null) {
            mainHandler.post { result.error("NOT_OPEN", "No document open", null) }
            return
        }
        try {
            // PdfRenderer is not thread-safe — synchronize across concurrent render calls
            val bytes = synchronized(renderer) {
                val page = renderer.openPage(index)
                val scale = width.toFloat() / page.width.toFloat()
                val height = (page.height * scale).toInt()
                val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                bitmap.eraseColor(Color.WHITE)
                page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                page.close()
                val stream = ByteArrayOutputStream()
                bitmap.compress(Bitmap.CompressFormat.PNG, 95, stream)
                bitmap.recycle()
                stream.toByteArray()
            }
            mainHandler.post { result.success(bytes) }
        } catch (e: Exception) {
            mainHandler.post { result.error("RENDER_ERROR", e.message, null) }
        }
    }

    private fun closeDocument() {
        pdfRenderer?.close()
        fileDescriptor?.close()
        pdfRenderer = null
        fileDescriptor = null
    }

    override fun onDestroy() {
        closeDocument()
        super.onDestroy()
    }
}
