import 'package:flutter/material.dart';
import '../container/fusion_overlay.dart';
import '../navigator/fusion_navigator_delegate.dart';

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
