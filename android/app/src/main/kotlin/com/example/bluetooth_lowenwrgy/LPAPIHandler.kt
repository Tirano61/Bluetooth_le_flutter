package com.dramirez.bluetooth_lowenwrgy

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import com.dothantech.lpapi.LPAPI 

class LPAPIHandler : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private val lpapi = LPAPI.Factory.createInstance() // Instancia de la biblioteca

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "flutter_lpapi")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "openPrinter" -> {
                val success = lpapi.openPrinter("") // Llama a un método de la biblioteca
                result.success(success)
            }
        /**
		 *	@param text = content,
		 *	@param v = x,
		 *	@param v1 = y,
		 *	@param v2 = width,
		 *	@param v3 = height,
		 *	@param v4 = fontWeiht,
		 * */
           "printText" -> {
                val text = call.argument<String>("text") ?: ""
                val x = call.argument<Double>("x") ?: 0.0
                val y = call.argument<Double>("y") ?: 0.0
                val width = call.argument<Double>("width") ?: 0.0
                val height = call.argument<Double>("height") ?: 0.0
                val fontWeight = call.argument<Double>("fontWeight") ?: 0.0

                lpapi.drawText(text, x, y, width, height, fontWeight) // Llama al método con los argumentos correctos
                result.success("Text printed successfully")
            }
            "startJob" -> {
                val width = call.argument<Double>("width") ?: 0.0
                val height = call.argument<Double>("height") ?: 0.0
                val orientation = call.argument<Int>("orientation") ?: 0

                lpapi.startJob(width, height, orientation) // Llama al método startJob
                result.success("Job started successfully")
            }
            "commitJob" -> {
                val success = lpapi.commitJob() 
                result.success(success)
            }
            "drawRoundRectangle" -> {
                val x = call.argument<Double>("x") ?: 0.0   
                val y = call.argument<Double>("y") ?: 0.0   
                val width = call.argument<Double>("width") ?: 0.0   
                val height = call.argument<Double>("height") ?: 0.0  
                val cornerWidth = call.argument<Double>("cornerWidth") ?: 0.0   
                val cornerHeight = call.argument<Double>("cornerHeight") ?: 0.0  
                val lineWidth = call.argument<Double>("lineWidth") ?: 0.0    

                lpapi.drawRoundRectangle(x, y, width, height, cornerWidth, cornerHeight, lineWidth) // Llama al método startJob
                result.success("Job started successfully")
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    /* private fun copyFontToInternalStorage(context: Context, fontName: String): String? {
        val assetManager = context.assets
        val file = File(context.filesDir, fontName)
        if (!file.exists()) {
            try {
                assetManager.open("fonts/$fontName").use { inputStream ->
                    FileOutputStream(file).use { outputStream ->
                        inputStream.copyTo(outputStream)
                    }
                }
            } catch (e: IOException) {
                e.printStackTrace()
                return null
            }
        }
        return file.absolutePath
    } */
   
}