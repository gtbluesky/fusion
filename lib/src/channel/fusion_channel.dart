import 'package:flutter/material.dart';
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
      // FusionLog.log('method=${call.method}');
      switch (call.method) {
        case 'push':
          final name = call.arguments['name'];
          final arguments = Map<String, dynamic>.from(call.arguments['arguments']);
          FusionNavigator.instance.push(name, arguments: arguments);
          break;
        case 'pop':
          FocusManager.instance.primaryFocus?.unfocus();
          await FusionNavigator.instance.pop();
          WidgetsBinding.instance?.drawFrame();
          break;
        case 'notifyPageVisible':
          final route = PageLifecycleBinding.instance.topRoute;
          PageLifecycleBinding.instance.dispatchPageVisibleEvent(route);
          break;
        case 'notifyPageInvisible':
          final route = PageLifecycleBinding.instance.topRoute;
          PageLifecycleBinding.instance.dispatchPageInvisibleEvent(route);
          break;
        case 'notifyEnterForeground':
          PageLifecycleBinding.instance.dispatchPageForegroundEvent();
          break;
        case 'notifyEnterBackground':
          PageLifecycleBinding.instance.dispatchPageBackgroundEvent();
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
