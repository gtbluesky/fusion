import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fusion/src/data/fusion_state.dart';
import 'package:fusion/src/extension/system_ui_overlay_extension.dart';
import 'package:fusion/src/lifecycle/page_lifecycle.dart';
import 'package:fusion/src/navigator/fusion_navigator.dart';
import 'package:fusion/src/navigator/fusion_navigator_delegate.dart';
import 'package:fusion/src/notification/page_notification.dart';
import 'package:fusion/src/route/fusion_page_route.dart';

class FusionChannel {
  FusionChannel._();

  static final FusionChannel _instance = FusionChannel._();

  static FusionChannel get instance => _instance;

  final MethodChannel _navigationChannel =
      const MethodChannel('fusion_navigation_channel');
  final MethodChannel _notificationChannel =
      const MethodChannel('fusion_notification_channel');
  final MethodChannel _platformChannel =
      const MethodChannel('fusion_platform_channel');

  void register() {
    _navigationChannel.setMethodCallHandler((call) async {
      // FusionLog.log('_navigationChannel method=${call.method}');
      switch (call.method) {
        case 'push':
          final name = call.arguments['name'];
          Map<String, dynamic>? arguments;
          if (call.arguments['arguments'] != null) {
            arguments = Map<String, dynamic>.from(call.arguments['arguments']);
          }
          await FusionNavigator.instance.push(name, arguments);
          break;
        case 'replace':
          final name = call.arguments['name'];
          Map<String, dynamic>? arguments;
          if (call.arguments['arguments'] != null) {
            arguments = Map<String, dynamic>.from(call.arguments['arguments']);
          }
          await FusionNavigator.instance.replace(name, arguments);
          break;
        case 'pop':
          final active = call.arguments['active'];
          if (active) {
            // 主动
            final result = call.arguments['result'];
            await FusionNavigator.instance.pop(result);
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
          await FusionNavigator.instance.remove(name);
          break;
        case 'restore':
          FusionState.isRestoring = true;
          final List<Map<String, dynamic>> list = [];
          call.arguments?.forEach((element) {
            list.add(element.cast<String, dynamic>());
          });
          if (list.isNotEmpty) {
            for (var element in list) {
              // print('restore:${element['name']}');
              FusionNavigator.instance.restore(element);
            }
          }
          break;
        default:
          break;
      }
    });
    _notificationChannel.setMethodCallHandler((call) async {
      // print('_notificationChannel method=${call.method}');
      switch (call.method) {
        case 'notifyPageVisible':
          /// 确保页面入栈后再调用生命周期方法
          WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
            // print('_notificationChannel run=${call.method}');
            final route = PageLifecycleBinding.instance.topRoute;
            _handlePageVisible(route);
          });
          break;
        case 'notifyPageInvisible':
          final route = PageLifecycleBinding.instance.topRoute;
          _handlePageInvisible(route);
          break;
        case 'notifyEnterForeground':
          PageLifecycleBinding.instance.dispatchPageForegroundEvent();
          break;
        case 'notifyEnterBackground':
          PageLifecycleBinding.instance.dispatchPageBackgroundEvent();
          break;
        case 'onReceive':
          if (call.arguments is! Map) {
            return;
          }
          Map<String, dynamic> msg = Map.from(call.arguments);
          String msgName = msg['msgName'];
          final msgBody = (msg['msgBody'] as Map?)?.cast<String, dynamic>();
          PageNotificationBinding.instance.dispatchPageMessage(msgName, msgBody);
          break;
        default:
          break;
      }
    });
    _platformChannel.setMethodCallHandler((call) async {
      // FusionLog.log('_platformChannel method=${call.method}');
      switch (call.method) {
        case 'latestStyle':
          return SystemChrome.latestStyle?.toMap();
        default:
          break;
      }
    });
  }

  void _handlePageVisible(
      Route? route, {
        bool isFirstTime = false,
      }) {
    if (route is FusionPageRoute && !route.isVisible) {
      route.containerInTop = true;
      if (route.isVisible) {
        PageLifecycleBinding.instance
            .dispatchPageVisibleEvent(route, isFirstTime: isFirstTime);
      }
    }
  }

  void _handlePageInvisible(Route? route) {
    if (route is FusionPageRoute) {
      if (route.isVisible) {
        PageLifecycleBinding.instance.dispatchPageInvisibleEvent(route);
      }
      route.containerInTop = false;
    }
  }

  Future<Map<String, dynamic>?> push(String name, dynamic arguments) async {
    final isFlutterPage = FusionNavigatorDelegate.instance.isFlutterPage(name);
    final result = await _navigationChannel.invokeMethod(
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
    final result = await _navigationChannel.invokeMethod(
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
    final result = await _navigationChannel.invokeMethod('pop');
    return result;
  }

  Future<bool> remove(String name) async {
    final result = await _navigationChannel.invokeMethod(
      'remove',
      {
        'name': name,
      },
    );
    return result;
  }

  Future<List<Map<String, dynamic>>> restoreHistory() async {
    final result =
        await _navigationChannel.invokeListMethod<Map>('restoreHistory');
    final List<Map<String, dynamic>> list = [];
    result?.forEach((element) {
      list.add(element.cast<String, dynamic>());
    });
    return list;
  }

  void sendMessage(String msgName, [Map<String, dynamic>? msgBody]) {
    _notificationChannel.invokeMethod(
      'sendMessage',
      {
        'msgName': msgName,
        'msgBody': msgBody,
      },
    );
  }
}
