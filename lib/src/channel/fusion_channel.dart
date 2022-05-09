import 'package:flutter/services.dart';

import '../lifecycle/page_lifecycle.dart';
import '../navigator/fusion_navigator.dart';
import '../notification/page_notification.dart';

class FusionChannel {
  static const MethodChannel _methodChannel = MethodChannel('fusion_channel');
  static const EventChannel _eventChannel =
      EventChannel('fusion_event_channel');

  static void register() {
    _methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'notifyPageVisible':
          final route = PageLifecycleBinding.instance.topRoute;
          PageLifecycleBinding.instance.dispatchPageVisibleEvent(route);
          // FusionLog.log(call.method);
          break;
        case 'notifyPageInvisible':
          final route = PageLifecycleBinding.instance.topRoute;
          PageLifecycleBinding.instance.dispatchPageInvisibleEvent(route);
          // FusionLog.log(call.method);
          break;
        case 'notifyEnterForeground':
          PageLifecycleBinding.instance.dispatchPageForegroundEvent();
          // FusionLog.log(call.method);
          break;
        case 'notifyEnterBackground':
          PageLifecycleBinding.instance.dispatchPageBackgroundEvent();
          // FusionLog.log(call.method);
          break;
        default:
          break;
      }
    });
    _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is! Map) {
        return;
      }
      Map<String, dynamic> msg = Map.from(event);
      String msgName = msg['msgName'];
      final msgBody = (msg['msgBody'] as Map?)?.cast<String, dynamic>();
      PageNotificationBinding.instance.dispatchPageMessage(msgName, msgBody);
    });
  }

  static Future<List<Map<String, dynamic>>?> push(
      String name, dynamic arguments) async {
    final isFlutterPage = FusionNavigator.instance.isFlutterPage(name);
    final List<dynamic>? result = await _methodChannel.invokeMethod('push',
        {'name': name, 'arguments': arguments, 'isFlutterPage': isFlutterPage});
    final List<Map<String, dynamic>> list = [];
    result?.cast<Map<dynamic, dynamic>>().forEach((element) {
      list.add(element.cast<String, dynamic>());
    });
    return list;
  }

  static Future<List<Map<String, dynamic>>?> pop() async {
    final List<dynamic>? result = await _methodChannel.invokeMethod('pop');
    final List<Map<String, dynamic>> list = [];
    result?.cast<Map<dynamic, dynamic>>().forEach((element) {
      list.add(element.cast<String, dynamic>());
    });
    return list;
  }

  static void sendMessage(String msgName, {Map<String, dynamic>? msgBody}) {
    _methodChannel
        .invokeMethod('sendMessage', {'msgName': msgName, 'msgBody': msgBody});
  }
}
