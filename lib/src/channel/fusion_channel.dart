import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fusion/src/container/fusion_overlay.dart';
import 'package:fusion/src/container/fusion_page.dart';
import 'package:fusion/src/data/fusion_state.dart';
import 'package:fusion/src/extension/system_ui_overlay_extension.dart';
import 'package:fusion/src/lifecycle/page_lifecycle.dart';
import 'package:fusion/src/navigator/fusion_navigator_delegate.dart';
import 'package:fusion/src/notification/fusion_notification.dart';

class FusionChannel {
  FusionChannel._();

  static final FusionChannel _instance = FusionChannel._();

  static FusionChannel get instance => _instance;

  final _navigationChannel =
      const MethodChannel('fusion_navigation_channel');
  final _notificationChannel =
      const MethodChannel('fusion_notification_channel');
  final _platformChannel =
      const MethodChannel('fusion_platform_channel');

  void register() {
    _navigationChannel.setMethodCallHandler((call) async {
      // print('_navigationChannel method=${call.method}');
      switch (call.method) {
        case 'open':
          String uniqueId = call.arguments['uniqueId'];
          String name = call.arguments['name'];
          Map<String, dynamic>? arguments;
          if (call.arguments['arguments'] != null) {
            arguments = Map<String, dynamic>.from(call.arguments['arguments']);
          }
          FusionNavigatorDelegate.instance.open(uniqueId, name, arguments);
          break;
        case 'push':
          String name = call.arguments['name'];
          Map<String, dynamic>? arguments;
          if (call.arguments['arguments'] != null) {
            arguments = Map<String, dynamic>.from(call.arguments['arguments']);
          }
          await FusionNavigatorDelegate.instance.push(name, arguments);
          break;
        case 'replace':
          String name = call.arguments['name'];
          Map<String, dynamic>? arguments;
          if (call.arguments['arguments'] != null) {
            arguments = Map<String, dynamic>.from(call.arguments['arguments']);
          }
          await FusionNavigatorDelegate.instance.replace(name, arguments);
          break;
        case 'pop':
          final result = call.arguments['result'];
          await FusionNavigatorDelegate.instance.pop(result);
          break;
        case 'remove':
          String name = call.arguments['name'];
          await FusionNavigatorDelegate.instance.remove(name);
          break;
        case 'destroy':
          FocusManager.instance.primaryFocus?.unfocus();
          String uniqueId = call.arguments['uniqueId'];
          await FusionNavigatorDelegate.instance.destroy(uniqueId);
          WidgetsBinding.instance?.drawFrame();
          break;
        case 'restore':
          FusionState.isRestoring = true;
          String uniqueId = call.arguments['uniqueId'];
          List history = call.arguments['history'];
          final list = <Map<String, dynamic>>[];
          for (var element in history) {
            list.add(element.cast<String, dynamic>());
          }
          if (list.isNotEmpty) {
            FusionNavigatorDelegate.instance.restore(uniqueId, list);
          }
          break;
        case 'switchTop':
          String uniqueId = call.arguments['uniqueId'];
          FusionOverlayManager.instance.switchTop(uniqueId);
          break;
        default:
          break;
      }
    });
    _notificationChannel.setMethodCallHandler((call) async {
      // print('_notificationChannel method=${call.method}');
      switch (call.method) {
        case 'notifyPageVisible':
          String uniqueId = call.arguments['uniqueId'];
          _handlePageVisible(uniqueId, isFirstTime: true);
          break;
        case 'notifyPageInvisible':
          String uniqueId = call.arguments['uniqueId'];
          _handlePageInvisible(uniqueId);
          break;
        case 'notifyEnterForeground':
          PageLifecycleBinding.instance.dispatchPageForegroundEvent();
          break;
        case 'notifyEnterBackground':
          PageLifecycleBinding.instance.dispatchPageBackgroundEvent();
          break;
        case 'dispatchMessage':
          if (call.arguments is! Map) {
            return;
          }
          final msg = Map<String, dynamic>.from(call.arguments);
          String name = msg['name'];
          final body = (msg['body'] as Map?)?.cast<String, dynamic>();
          FusionNotificationBinding.instance.dispatchMessage(name, body);
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
    String uniqueId, {
    bool isFirstTime = false,
  }) {
    final page = FusionOverlayManager.instance.findContainer(uniqueId)?.topPage;
    if (page == null) return;
    if (!page.isVisible) {
      page.containerVisible = true;
      if (page.isVisible) {
        PageLifecycleBinding.instance
            .dispatchPageVisibleEvent(page.route, isFirstTime: isFirstTime);
      }
    }
  }

  void _handlePageInvisible(String uniqueId) {
    final page = FusionOverlayManager.instance.findContainer(uniqueId)?.topPage;
    if (page == null) return;
    if (page.isVisible) {
      PageLifecycleBinding.instance.dispatchPageInvisibleEvent(page.route);
    }
    page.containerVisible = false;
  }

  Future sync(String uniqueId, List<FusionPageEntity> pageEntities) {
    final pages = pageEntities.map((e) => {
      'uniqueId': e.uniqueId,
      'name': e.name,
      'arguments': e.arguments,
    }).toList();
    return _navigationChannel.invokeMethod(
      'sync',
      {
        'uniqueId': uniqueId,
        'pages': pages,
      },
    );
  }

  Future open(String name, dynamic arguments) {
    return _navigationChannel.invokeMethod(
      'open',
      {
        'name': name,
        'arguments': arguments,
      },
    );
  }

  Future push(String name, dynamic arguments) async {
    return _navigationChannel.invokeMethod(
      'push',
      {
        'name': name,
        'arguments': arguments,
      },
    );
  }

  Future<bool> destroy(String uniqueId) async {
    final result = await _navigationChannel.invokeMethod(
      'destroy',
      {
        'uniqueId': uniqueId,
      },
    );
    return result;
  }

  Future<List<Map<String, dynamic>>> restore() async {
    final result =
        await _navigationChannel.invokeListMethod<Map>('restore');
    final List<Map<String, dynamic>> list = [];
    result?.forEach((element) {
      list.add(element.cast<String, dynamic>());
    });
    return list;
  }

  void sendMessage(String name, [Map<String, dynamic>? body]) {
    _notificationChannel.invokeMethod(
      'sendMessage',
      {
        'name': name,
        'body': body,
      },
    );
  }
}
