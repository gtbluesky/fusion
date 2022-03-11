import 'package:flutter/services.dart';

class FusionChannel {
  static const MethodChannel _channel = MethodChannel('fusion_channel');

  static Future<void> push(String name, [dynamic arguments]) async {
    await _channel.invokeMethod('push', {'name': name, 'arguments': arguments});
  }

  static Future<void> pop() async {
    await _channel.invokeMethod('pop');
  }
}
