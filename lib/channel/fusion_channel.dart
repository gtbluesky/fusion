import 'package:flutter/services.dart';
import 'package:fusion/fusion.dart';

class FusionChannel {
  static const MethodChannel _channel = MethodChannel('fusion_channel');

  static void register() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onPageVisible':
          final route = PageLifecycleBinding.instance.topRoute;
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

  static Future<List<Map<String, dynamic>>?> push(
      String name, dynamic arguments) async {
    final isFlutterPage = FusionNavigator.instance.isFlutterPage(name);
    final List<dynamic>? result = await _channel.invokeMethod('push',
        {'name': name, 'arguments': arguments, 'isFlutterPage': isFlutterPage});
    final List<Map<String, dynamic>> list = [];
    result?.cast<Map<dynamic, dynamic>>().forEach((element) {
      list.add(element.cast<String, dynamic>());
    });
    return list;
  }

  static Future<List<Map<String, dynamic>>?> pop() async {
    final List<dynamic>? result = await _channel.invokeMethod('pop');
    final List<Map<String, dynamic>> list = [];
    result?.cast<Map<dynamic, dynamic>>().forEach((element) {
      list.add(element.cast<String, dynamic>());
    });
    return list;
  }
}
