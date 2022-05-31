import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../lifecycle/page_lifecycle.dart';
import '../navigator/fusion_navigator.dart';
import '../notification/page_notification.dart';

class FusionChannel {
  FusionChannel._();

  static final FusionChannel _instance = FusionChannel._();

  static FusionChannel get instance => _instance;

  final MethodChannel _methodChannel = const MethodChannel('fusion_channel');
  final EventChannel _eventChannel = const EventChannel('fusion_event_channel');

  void register() {
    _methodChannel.setMethodCallHandler((call) async {
      // FusionLog.log('method=${call.method}');
      switch (call.method) {
        case 'push':
          final name = call.arguments['name'];
          final arguments =
              Map<String, dynamic>.from(call.arguments['arguments']);
          FusionNavigator.instance.push(name, arguments);
          break;
        case 'replace':
          final name = call.arguments['name'];
          final arguments =
              Map<String, dynamic>.from(call.arguments['arguments']);
          FusionNavigator.instance.replace(name, arguments);
          break;
        case 'pop':
          final active = call.arguments['active'];
          // 主动
          if (active) {
            final result = call.arguments['result'];
            FusionNavigator.instance.pop(result);
          } else {
            // 被动
            // 即容器销毁后处理Flutter路由战
            FocusManager.instance.primaryFocus?.unfocus();
            await FusionNavigator.instance.pop();
            WidgetsBinding.instance?.drawFrame();
          }
          break;
        case 'remove':
          final name = call.arguments['name'];
          final all = call.arguments['all'];
          FusionNavigator.instance.remove(name, all);
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

  Future<List<Map<String, dynamic>>?> push(
      String name, dynamic arguments) async {
    final isFlutterPage = FusionNavigator.instance.isFlutterPage(name);
    final List<dynamic>? result = await _methodChannel.invokeMethod('push',
        {'name': name, 'arguments': arguments, 'isFlutterPage': isFlutterPage});
    List<Map<String, dynamic>>? list;
    if (result != null) {
      list = [];
    }
    result?.cast<Map<dynamic, dynamic>>().forEach((element) {
      list?.add(element.cast<String, dynamic>());
    });
    return list;
  }

  Future<List<Map<String, dynamic>>?> replace(
      String name, dynamic arguments) async {
    final isFlutterPage = FusionNavigator.instance.isFlutterPage(name);
    if (!isFlutterPage) {
      throw Exception('Route name is not found in route map!');
    }
    final List<dynamic>? result = await _methodChannel
        .invokeMethod('replace', {'name': name, 'arguments': arguments});
    List<Map<String, dynamic>>? list;
    if (result != null) {
      list = [];
    }
    result?.cast<Map<dynamic, dynamic>>().forEach((element) {
      list?.add(element.cast<String, dynamic>());
    });
    return list;
  }

  Future<List<Map<String, dynamic>>?> pop() async {
    final List<dynamic>? result = await _methodChannel.invokeMethod('pop');
    List<Map<String, dynamic>>? list;
    if (result != null) {
      list = [];
    }
    result?.cast<Map<dynamic, dynamic>>().forEach((element) {
      list?.add(element.cast<String, dynamic>());
    });
    return list;
  }

  Future<List<Map<String, dynamic>>?> remove(String name, bool all) async {
    final List<dynamic>? result =
        await _methodChannel.invokeMethod('remove', {'name': name, 'all': all});
    List<Map<String, dynamic>>? list;
    if (result != null) {
      list = [];
    }
    result?.cast<Map<dynamic, dynamic>>().forEach((element) {
      list?.add(element.cast<String, dynamic>());
    });
    return list;
  }

  void sendMessage(String msgName, [Map<String, dynamic>? msgBody]) {
    _methodChannel
        .invokeMethod('sendMessage', {'msgName': msgName, 'msgBody': msgBody});
  }
}
