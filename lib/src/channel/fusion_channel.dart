import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fusion/src/navigator/fusion_navigator_delegate.dart';

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
          Map<String, dynamic>? arguments;
          if (call.arguments['arguments'] != null) {
            arguments = Map<String, dynamic>.from(call.arguments['arguments']);
          }
          FusionNavigator.instance.push(name, arguments);
          break;
        case 'replace':
          final name = call.arguments['name'];
          Map<String, dynamic>? arguments;
          if (call.arguments['arguments'] != null) {
            arguments = Map<String, dynamic>.from(call.arguments['arguments']);
          }
          FusionNavigator.instance.replace(name, arguments);
          break;
        case 'pop':
          final active = call.arguments['active'];
          if (active) {
            // 主动
            final result = call.arguments['result'];
            FusionNavigator.instance.pop(result);
          } else {
            // 被动
            // 即容器销毁后处理Flutter路由栈
            FocusManager.instance.primaryFocus?.unfocus();
            await FusionNavigatorDelegate.instance.directPop();
            WidgetsBinding.instance?.drawFrame();
          }
          break;
        case 'remove':
          final name = call.arguments['name'];
          FusionNavigator.instance.remove(name);
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

  Future<Map<String, dynamic>?> push(String name, dynamic arguments) async {
    final isFlutterPage = FusionNavigatorDelegate.instance.isFlutterPage(name);
    final result = await _methodChannel.invokeMethod(
      'push',
      {
        'name': name,
        'arguments': arguments,
        'flutter': isFlutterPage,
      },
    );
    if (result == null) {
      return null;
    }
    return Map<String, dynamic>.from(result);
  }

  Future<Map<String, dynamic>?> replace(String name, dynamic arguments) async {
    final isFlutterPage = FusionNavigatorDelegate.instance.isFlutterPage(name);
    if (!isFlutterPage) {
      throw Exception('Route name is not found in route map!');
    }
    final result = await _methodChannel.invokeMethod(
      'replace',
      {
        'name': name,
        'arguments': arguments,
        'flutter': isFlutterPage,
      },
    );
    if (result == null) {
      return null;
    }
    return Map<String, dynamic>.from(result);
  }

  Future<bool> pop() async {
    final result = await _methodChannel.invokeMethod('pop');
    return result;
  }

  Future<bool> remove(String name) async {
    final result = await _methodChannel.invokeMethod(
      'remove',
      {
        'name': name,
      },
    );
    return result;
  }

  void sendMessage(String msgName, [Map<String, dynamic>? msgBody]) {
    _methodChannel.invokeMethod(
      'sendMessage',
      {
        'msgName': msgName,
        'msgBody': msgBody,
      },
    );
  }
}
