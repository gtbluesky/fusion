import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../container/fusion_overlay.dart';
import '../container/fusion_page.dart';
import '../data/fusion_state.dart';
import '../event/fusion_event.dart';
import '../extension/system_ui_overlay_extension.dart';
import '../fusion.dart';
import '../lifecycle/fusion_app_lifecycle.dart';
import '../lifecycle/fusion_page_lifecycle.dart';
import '../navigator/fusion_navigator.dart';
import '../navigator/fusion_navigator_delegate.dart';

class FusionChannel {
  FusionChannel._();

  static final FusionChannel _instance = FusionChannel._();

  static FusionChannel get instance => _instance;

  static const _fusionChannel = 'fusion_channel';

  final _hostPush = const BasicMessageChannel(
      '$_fusionChannel/host/push', StandardMessageCodec());
  final _hostDestroy = const BasicMessageChannel(
      '$_fusionChannel/host/destroy', StandardMessageCodec());
  final _hostRestore = const BasicMessageChannel(
      '$_fusionChannel/host/restore', StandardMessageCodec());
  final _hostSync = const BasicMessageChannel(
      '$_fusionChannel/host/sync', StandardMessageCodec());
  final _hostDispatchEvent = const BasicMessageChannel(
      '$_fusionChannel/host/dispatchEvent', StandardMessageCodec());
  final _flutterCreate = const BasicMessageChannel(
      '$_fusionChannel/flutter/create', StandardMessageCodec());
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
  final _flutterDispatchEvent = const BasicMessageChannel(
      '$_fusionChannel/flutter/dispatchEvent', StandardMessageCodec());
  final _flutterCheckStyle = const BasicMessageChannel(
      '$_fusionChannel/flutter/checkStyle', StandardMessageCodec());

  void register() {
    // external function
    _flutterPush.setMessageHandler((message) async {
      if (message is! Map) return null;
      String name = message['name'];
      Map<String, dynamic>? args;
      if (message['args'] != null) {
        try {
          args = jsonDecode(jsonEncode(message['args']));
        } catch (e) {
          args = null;
        }
      }
      final type = FusionRouteType.values[message['type']];
      return FusionNavigatorDelegate.instance.push(name, args, type);
    });
    _flutterReplace.setMessageHandler((message) async {
      if (message is! Map) return null;
      String name = message['name'];
      Map<String, dynamic>? args;
      if (message['args'] != null) {
        try {
          args = jsonDecode(jsonEncode(message['args']));
        } catch (e) {
          args = null;
        }
      }
      return FusionNavigatorDelegate.instance.replace(name, args);
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
    // internal function
    _flutterCreate.setMessageHandler((message) async {
      FusionJobQueue.instance.runJob(() {
        if (message is! Map) return null;
        String uniqueId = message['uniqueId'];
        String name = message['name'];
        Map<String, dynamic>? args;
        if (message['args'] != null) {
          try {
            args = jsonDecode(jsonEncode(message['args']));
          } catch (e) {
            args = null;
          }
        }
        FusionNavigatorDelegate.instance.create(uniqueId, name, args);
      });
      return null;
    });
    _flutterSwitchTop.setMessageHandler((message) async {
      FusionJobQueue.instance.runJob(() {
        if (message is! Map) return;
        String uniqueId = message['uniqueId'];
        FusionOverlayManager.instance.switchTop(uniqueId);
      });
      return null;
    });
    _flutterRestore.setMessageHandler((message) async {
      FusionJobQueue.instance.runJob(() {
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
      });
      return;
    });
    _flutterDestroy.setMessageHandler((message) async {
      if (message is! Map) return;
      FocusManager.instance.primaryFocus?.unfocus();
      String uniqueId = message['uniqueId'];
      FusionOverlayManager.instance.remove(uniqueId);
      // ignore: invalid_null_aware_operator
      WidgetsBinding.instance?.drawFrame();
      return null;
    });
    _flutterNotifyPageVisible.setMessageHandler((message) async {
      FusionJobQueue.instance.runJob(() {
        if (message is! Map) return;
        String uniqueId = message['uniqueId'];
        _handlePageVisible(uniqueId, isFirstTime: true);
      });
      return;
    });
    _flutterNotifyPageInvisible.setMessageHandler((message) async {
      FusionJobQueue.instance.runJob(() {
        if (message is! Map) return;
        String uniqueId = message['uniqueId'];
        _handlePageInvisible(uniqueId);
      });
      return;
    });
    _flutterNotifyEnterForeground.setMessageHandler((message) async {
      FusionAppLifecycleManager.instance.dispatchAppForegroundEvent();
      FusionPageLifecycleManager.instance.dispatchPageForegroundEvent();
      return;
    });
    _flutterNotifyEnterBackground.setMessageHandler((message) async {
      FusionAppLifecycleManager.instance.dispatchAppBackgroundEvent();
      FusionPageLifecycleManager.instance.dispatchPageBackgroundEvent();
      return;
    });
    _flutterDispatchEvent.setMessageHandler((message) async {
      FusionJobQueue.instance.runJob(() {
        if (message is! Map) return;
        final msg = Map<String, dynamic>.from(message);
        String name = msg['name'];
        final args = (msg['args'] as Map?)?.cast<String, dynamic>();
        FusionEventManager.instance
            .send(name, args: args, type: FusionEventType.flutter);
      });
      return;
    });
    _flutterCheckStyle.setMessageHandler((message) async {
      // ignore: invalid_use_of_visible_for_testing_member
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
        FusionPageLifecycleManager.instance
            .dispatchPageVisibleEvent(page.route, isFirstTime: isFirstTime);
      }
    }
  }

  void _handlePageInvisible(String uniqueId) {
    final page = FusionOverlayManager.instance.findContainer(uniqueId)?.topPage;
    if (page == null) return;
    if (page.isVisible) {
      FusionPageLifecycleManager.instance
          .dispatchPageInvisibleEvent(page.route);
    }
    page.containerVisible = false;
  }

  void sync(String uniqueId, List<FusionPageEntity> pageEntities) {
    final history = pageEntities
        .map((e) => {
              'uniqueId': e.uniqueId,
              'name': e.name,
              'args': sanitizeForStandardMessageCodec(e.args),
            })
        .toList();
    if (history.length == 1) {
      // ignore: invalid_null_aware_operator
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        final topRoute = FusionOverlayManager.instance.topRoute;
        if (topRoute is PageRoute) {
          _hostSync.send({
            // ignore: invalid_use_of_protected_member
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

  Future push(String name, dynamic args, FusionRouteType type) async {
    return _hostPush.send({
      'name': name,
      'args': args,
      'type': type.index,
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

  void dispatchEvent(String name, [Map<String, dynamic>? args]) {
    _hostDispatchEvent.send({
      'name': name,
      'args': args,
    });
  }
}

const Object _kOmitHostSyncValue = Object();

/// Returns a [StandardMessageCodec]-safe copy of [value].
///
/// [Function] callbacks and other types the codec cannot encode are omitted
/// (dropped from [Map]s and [List]s). Encodable values are left unchanged.
Object? sanitizeForStandardMessageCodec(Object? value) {
  final sanitized = _sanitizeForStandardMessageCodec(value);
  return identical(sanitized, _kOmitHostSyncValue) ? null : sanitized;
}

Object? _sanitizeForStandardMessageCodec(Object? value) {
  if (value is Function) {
    return _kOmitHostSyncValue;
  }
  if (value is Map) {
    final result = <Object?, Object?>{};
    value.forEach((key, val) {
      final sanitizedKey = _sanitizeForStandardMessageCodec(key);
      final sanitizedVal = _sanitizeForStandardMessageCodec(val);
      if (!identical(sanitizedKey, _kOmitHostSyncValue) &&
          !identical(sanitizedVal, _kOmitHostSyncValue)) {
        result[sanitizedKey] = sanitizedVal;
      }
    });
    return result;
  }
  // Typed data lists are themselves [List]s; keep them intact when the codec
  // supports them instead of rewriting element-by-element.
  if (value is List && value is! TypedData) {
    final result = <Object?>[];
    for (final item in value) {
      final sanitized = _sanitizeForStandardMessageCodec(item);
      if (!identical(sanitized, _kOmitHostSyncValue)) {
        result.add(sanitized);
      }
    }
    return result;
  }
  try {
    const StandardMessageCodec().encodeMessage(value);
    return value;
  } catch (_) {
    return _kOmitHostSyncValue;
  }
}
