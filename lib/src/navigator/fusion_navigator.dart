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
  }) {
    return FusionNavigatorDelegate.instance
        .push<T>(routeName, routeArgs, routeType);
  }

  /// Push a new page and clear the stack.
  static Future<T?> pushAndClear<T extends Object?>(
    String routeName, {
    Map<String, dynamic>? routeArgs,
  }) {
    return FusionNavigatorDelegate.instance
        .pushAndClear<T>(routeName, routeArgs);
  }

  /// Replace a designated flutter page with a new flutter page in the current container.
  static Future<T?> replace<T extends Object?>(
    String routeName, [
    Map<String, dynamic>? routeArgs,
    bool animated = false,
  ]) {
    return FusionNavigatorDelegate.instance
        .replace<T>(routeName, routeArgs, animated);
  }

  /// Pop in the current container.
  static Future<void> pop<T extends Object?>([T? result]) {
    return FusionNavigatorDelegate.instance.pop<T>(result);
  }

  /// Calls [pop] repeatedly until the predicate returns true.
  static Future<void> popUntil(String routeName) {
    return FusionNavigatorDelegate.instance.popUntil(routeName);
  }

  /// Pop in the current container.
  /// Can be used with [WillPopScope].
  static Future<bool> maybePop<T extends Object?>([T? result]) {
    return FusionNavigatorDelegate.instance.maybePop<T>(result);
  }

  /// Remove a designated flutter page in all containers.
  static Future<void> remove(String routeName) {
    return FusionNavigatorDelegate.instance.remove(routeName);
  }

  static bool hasRouteByName(String routeName) {
    return FusionNavigatorDelegate.instance.hasRouteByName(routeName);
  }

  static bool hasPageByName(String routeName) {
    return FusionNavigatorDelegate.instance.hasPageByName(routeName);
  }

  static String get topPageRouteName =>
      FusionNavigatorDelegate.instance.topPageRouteName;

  static String? get topRouteName =>
      FusionOverlayManager.instance.topRoute?.settings.name;

  static Route? get topRoute => FusionOverlayManager.instance.topRoute;

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
