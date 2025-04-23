package com.dramirez.bluetooth_lowenwrgy

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

// Importa las clases de la librería .jar
import com.dothantech.lpapi.LPAPI; // Cambia esto según el paquete de la librería

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.dothantech.lpapi.LPAPI/channel";
    private LPAPI lpapi;

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // Inicializa la librería
        lpapi = new LPAPI();

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("initializePrinter")) {
                     lpapi= LPAPI.Factory.createInstance(); // Llama a un método de la librería
                    result.success(success);
                } else {
                    result.notImplemented();
                }
            });
    }
}