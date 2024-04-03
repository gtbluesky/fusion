import 'package:flutter/material.dart';
import '../channel/fusion_channel.dart';
import '../container/fusion_overlay.dart';
import '../navigator/fusion_navigator_delegate.dart';
import '../notification/fusion_notification.dart';

class FusionNavigator {
  FusionNavigator._();

  /// Push a new page.
  static Future<T?> push<T extends Object?>(
    String routeName, {
    Map<String, dynamic>? routeArgs,
    FusionRouteType routeType = FusionRouteType.adaption,
  }) async {
    return FusionNavigatorDelegate.instance
        .push(routeName, routeArgs, routeType);
  }

  /// Replace a designated flutter page with a new flutter page in the current container.
  static Future<T?> replace<T extends Object?>(
    String routeName, [
    Map<String, dynamic>? routeArgs,
    bool animated = false,
  ]) async {
    return FusionNavigatorDelegate.instance
        .replace(routeName, routeArgs, animated);
  }

  /// Pop in the current container.
  static Future<void> pop<T extends Object?>([T? result]) async {
    return FusionNavigatorDelegate.instance.pop(result);
  }

  /// Pop in the current container.
  /// Can be used with [WillPopScope].
  static Future<bool> maybePop<T extends Object?>([T? result]) async {
    return FusionNavigatorDelegate.instance.maybePop(result);
  }

  /// Remove a designated flutter page in all containers.
  static Future<void> remove(String routeName) async {
    return FusionNavigatorDelegate.instance.remove(routeName);
  }

  /// Send a message to flutter side and native side.
  static void sendMessage(
    String name, {
    Map<String, dynamic>? body,
    FusionNotificationType type = FusionNotificationType.global,
  }) {
    switch (type) {
      case FusionNotificationType.flutter:
        FusionNotificationBinding.instance.dispatchMessage(name, body);
        break;
      case FusionNotificationType.native:
        FusionChannel.instance.dispatchMessage(name, body);
        break;
      case FusionNotificationType.global:
        FusionNotificationBinding.instance.dispatchMessage(name, body);
        FusionChannel.instance.dispatchMessage(name, body);
        break;
    }
  }

  static NavigatorState? get navigator =>
      FusionOverlayManager.instance.topRoute?.navigator;

  static BuildContext? get context => navigator?.context;
}

enum FusionRouteType {
  flutter,
  flutterWithContainer,
  native,
  adaption;
}
