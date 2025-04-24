package com.dramirez.bluetooth_lowenwrgy

import io.flutter.embedding.android.FlutterActivity
import com.dramirez.bluetooth_lowenwrgy.LPAPIHandler
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(LPAPIHandler())
    }
}
