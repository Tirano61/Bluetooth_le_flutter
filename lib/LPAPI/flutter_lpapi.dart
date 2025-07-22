

import 'package:flutter/services.dart';

class FlutterLpapi {
  static const MethodChannel _channel = MethodChannel('flutter_lpapi');

  static Future<bool> openPrinter() async {
    final bool result =  await _channel.invokeMethod('openPrinter');
    return result;
  }

  static Future<void> startJob({
    required double width,
    required double height,
    required int orientation,
  }) async {
    await _channel.invokeMethod('startJob', {
      'width'      : width,
      'height'     : height,
      'orientation': orientation,
    });
  }

  static Future<void> printText({
    required String text,
    required double x,
    required double y,
    required double width,
    required double height,
    required double fontWeight,
  }) async {
    await _channel.invokeMethod('printText', {
      'text': text,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'fontWeight': fontWeight,
    });
  }
  static Future<void> drawRoundRectangle({
    required double x,
    required double y,
    required double width,
    required double height,
    required double cornerWidth,
    required double cornerHeight,
    required double lineWidth,
  }) async {
    await _channel.invokeMethod('drawRoundRectangle', {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'cornerWidth': cornerWidth,
      'cornerHeight': cornerHeight,
      'lineWidth': lineWidth,
    });
  }

  static Future<void> commitJob() async{
    await _channel.invokeMethod('commitJob');
  }
}