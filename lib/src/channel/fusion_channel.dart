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

  static const _fusionChannel = 'fusion_channel';

  final _hostOpen = const BasicMessageChannel(
      '$_fusionChannel/host/open', StandardMessageCodec());
  final _hostPush = const BasicMessageChannel(
      '$_fusionChannel/host/push', StandardMessageCodec());
  final _hostDestroy = const BasicMessageChannel(
      '$_fusionChannel/host/destroy', StandardMessageCodec());
  final _hostRestore = const BasicMessageChannel(
      '$_fusionChannel/host/restore', StandardMessageCodec());
  final _hostSync = const BasicMessageChannel(
      '$_fusionChannel/host/sync', StandardMessageCodec());
  final _hostSendMessage = const BasicMessageChannel(
      '$_fusionChannel/host/sendMessage', StandardMessageCodec());
  final _hostRemoveMaskView = const BasicMessageChannel(
      '$_fusionChannel/host/removeMaskView', StandardMessageCodec());
  final _flutterOpen = const BasicMessageChannel(
      '$_fusionChannel/flutter/open', StandardMessageCodec());
  final _flutterSwitchTop = const BasicMessageChannel(
      '$_fusionChannel/flutter/switchTop', StandardMessageCodec());
  final _flutterRestore = const BasicMessageChannel(
      '$_fusionChannel/flutter/restore', StandardMessageCodec());
  final _flutterDestroy = const BasicMessageChannel(
      '$_fusionChannel/flutter/destroy', StandardMessageCodec());
  final _flutterPush = const BasicMessageChannel(
      '$_fusionChannel/flutter/push', StandardMessageCodec());
  final _flutterReplace = const BasicMessageChannel(
      '$_fusionChannel/flutter/replace', StandardMessageCodec());
  final _flutterPop = const BasicMessageChannel(
      '$_fusionChannel/flutter/pop', StandardMessageCodec());
  final _flutterMaybePop = const BasicMessageChannel(
      '$_fusionChannel/flutter/maybePop', StandardMessageCodec());
  final _flutterRemove = const BasicMessageChannel(
      '$_fusionChannel/flutter/remove', StandardMessageCodec());
  final _flutterNotifyPageVisible = const BasicMessageChannel(
      '$_fusionChannel/flutter/notifyPageVisible', StandardMessageCodec());
  final _flutterNotifyPageInvisible = const BasicMessageChannel(
      '$_fusionChannel/flutter/notifyPageInvisible', StandardMessageCodec());
  final _flutterNotifyEnterForeground = const BasicMessageChannel(
      '$_fusionChannel/flutter/notifyEnterForeground', StandardMessageCodec());
  final _flutterNotifyEnterBackground = const BasicMessageChannel(
      '$_fusionChannel/flutter/notifyEnterBackground', StandardMessageCodec());
  final _flutterDispatchMessage = const BasicMessageChannel(
      '$_fusionChannel/flutter/dispatchMessage', StandardMessageCodec());
  final _flutterCheckStyle = const BasicMessageChannel(
      '$_fusionChannel/flutter/checkStyle', StandardMessageCodec());

  void register() {
    _flutterOpen.setMessageHandler((message) async {
      if (message is! Map) return null;
      String uniqueId = message['uniqueId'];
      String name = message['name'];
      Map<String, dynamic>? arguments;
      if (message['arguments'] != null) {
        arguments = Map<String, dynamic>.from(message['arguments']);
      }
      FusionNavigatorDelegate.instance.open(uniqueId, name, arguments);
      removeMaskView(uniqueId);
      return null;
    });
    _flutterPush.setMessageHandler((message) async {
      if (message is! Map) return null;
      String name = message['name'];
      Map<String, dynamic>? arguments;
      if (message['arguments'] != null) {
        arguments = Map<String, dynamic>.from(message['arguments']);
      }
      return FusionNavigatorDelegate.instance.push(name, arguments);
    });
    _flutterReplace.setMessageHandler((message) async {
      if (message is! Map) return null;
      String name = message['name'];
      Map<String, dynamic>? arguments;
      if (message['arguments'] != null) {
        arguments = Map<String, dynamic>.from(message['arguments']);
      }
      return FusionNavigatorDelegate.instance.replace(name, arguments);
    });
    _flutterPop.setMessageHandler((message) async {
      if (message is! Map) return;
      final result = message['result'];
      return FusionNavigatorDelegate.instance.pop(result);
    });
    _flutterMaybePop.setMessageHandler((message) async {
      if (message is! Map) return false;
      final result = message['result'];
      return FusionNavigatorDelegate.instance.maybePop(result);
    });
    _flutterRemove.setMessageHandler((message) async {
      if (message is! Map) return;
      String name = message['name'];
      return FusionNavigatorDelegate.instance.remove(name);
    });
    _flutterDestroy.setMessageHandler((message) async {
      if (message is! Map) return;
      FocusManager.instance.primaryFocus?.unfocus();
      String uniqueId = message['uniqueId'];
      await FusionNavigatorDelegate.instance.destroy(uniqueId);
      WidgetsBinding.instance?.drawFrame();
      return null;
    });
    _flutterRestore.setMessageHandler((message) async {
      if (message is! Map) return;
      FusionState.isRestoring = true;
      String uniqueId = message['uniqueId'];
      List history = message['history'];
      final list = <Map<String, dynamic>>[];
      for (var element in history) {
        list.add(element.cast<String, dynamic>());
      }
      if (list.isEmpty) {
        return;
      }
      FusionNavigatorDelegate.instance.restore(uniqueId, list);
      removeMaskView(uniqueId);
    });
    _flutterSwitchTop.setMessageHandler((message) async {
      if (message is! Map) return;
      String uniqueId = message['uniqueId'];
      return FusionOverlayManager.instance.switchTop(uniqueId);
    });
    _flutterNotifyPageVisible.setMessageHandler((message) async {
      if (message is! Map) return;
      String uniqueId = message['uniqueId'];
      _handlePageVisible(uniqueId, isFirstTime: true);
    });
    _flutterNotifyPageInvisible.setMessageHandler((message) async {
      if (message is! Map) return;
      String uniqueId = message['uniqueId'];
      _handlePageInvisible(uniqueId);
    });
    _flutterNotifyEnterForeground.setMessageHandler((message) async {
      PageLifecycleBinding.instance.dispatchPageForegroundEvent();
    });
    _flutterNotifyEnterBackground.setMessageHandler((message) async {
      PageLifecycleBinding.instance.dispatchPageBackgroundEvent();
    });
    _flutterDispatchMessage.setMessageHandler((message) async {
      if (message is! Map) return;
      final msg = Map<String, dynamic>.from(message);
      String name = msg['name'];
      final body = (msg['body'] as Map?)?.cast<String, dynamic>();
      FusionNotificationBinding.instance.dispatchMessage(name, body);
    });
    _flutterCheckStyle.setMessageHandler((message) async {
      return SystemChrome.latestStyle?.toMap();
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

  void sync(String uniqueId, List<FusionPageEntity> pageEntities) {
    final history = pageEntities
        .map((e) => {
              'uniqueId': e.uniqueId,
              'name': e.name,
              'arguments': e.arguments,
            })
        .toList();
    if (history.length == 1) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        final topRoute = FusionOverlayManager.instance.topRoute;
        if (topRoute is PageRoute) {
          _hostSync.send({
            'hostPopGesture': !topRoute.hasScopedWillPopCallback,
            'uniqueId': uniqueId,
            'history': history,
          });
        }
      });
    } else {
      _hostSync.send({
        'hostPopGesture': false,
        'uniqueId': uniqueId,
        'history': history,
      });
    }
  }

  Future open(String name, dynamic arguments) {
    return _hostOpen.send({
      'name': name,
      'arguments': arguments,
    });
  }

  Future push(String name, dynamic arguments) async {
    return _hostPush.send({
      'name': name,
      'arguments': arguments,
    });
  }

  Future<bool> destroy(String uniqueId) async {
    final result = await _hostDestroy.send({
      'uniqueId': uniqueId,
    });
    return (result is bool) ? result : false;
  }

  Future<List<Map<String, dynamic>>> restore() async {
    final result = await _hostRestore.send(null);
    final List<Map<String, dynamic>> list = [];
    (result as List?)?.forEach((element) {
      list.add(element.cast<String, dynamic>());
    });
    return list;
  }

  void sendMessage(String name, [Map<String, dynamic>? body]) {
    _hostSendMessage.send({
      'name': name,
      'body': body,
    });
  }

  void removeMaskView(String uniqueId) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        // callback of the next frame completes
        _hostRemoveMaskView.send({
          'uniqueId': uniqueId,
        });
      });
    });
  }
}
