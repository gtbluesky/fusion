import 'package:flutter/services.dart';
import 'package:fusion/fusion.dart';

import '../log/fusion_log.dart';

class FusionChannel {
  static const MethodChannel _channel = MethodChannel('fusion_channel');

  static void register() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onPageVisible':
          final route = PageLifecycleBinding.instance.topRoute;
          // FusionLog.log('toproute:${route.runtimeType}@${route.hashCode}');
          PageLifecycleBinding.instance.dispatchPageVisibleEvent(route);
          // FusionLog.log(call.method);
          break;
        case 'onPageInvisible':
          final route = PageLifecycleBinding.instance.topRoute;
          PageLifecycleBinding.instance.dispatchPageInvisibleEvent(route);
          // FusionLog.log(call.method);
          break;
        case 'onForeground':
          PageLifecycleBinding.instance.dispatchPageForegroundEvent();
          // FusionLog.log(call.method);
          break;
        case 'onBackground':
          PageLifecycleBinding.instance.dispatchPageBackgroundEvent();
          // FusionLog.log(call.method);
          break;
        default:
          break;
      }
    });
  }

  static Future<void> push(String name, [dynamic arguments]) async {
    await _channel.invokeMethod('push', {'name': name, 'arguments': arguments});
  }

  static Future<void> pop() async {
    await _channel.invokeMethod('pop');
  }
}
