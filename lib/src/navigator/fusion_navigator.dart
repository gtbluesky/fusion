import 'package:flutter/material.dart';
import 'package:fusion/src/channel/fusion_channel.dart';
import 'package:fusion/src/container/fusion_overlay.dart';
import 'package:fusion/src/navigator/fusion_navigator_delegate.dart';

class FusionNavigator {
  FusionNavigator._();

  static final FusionNavigator _instance = FusionNavigator._();

  static FusionNavigator get instance => _instance;

  /// Open a new container and push a new flutter page on the route stack.
  Future open(
    String routeName, [
    Map<String, dynamic>? routeArgs,
  ]) {
    return FusionChannel.instance.open(routeName, routeArgs);
  }

  /// Push a new flutter page in the current container.
  Future<T?> push<T extends Object?>(
    String routeName, [
    Map<String, dynamic>? routeArgs,
  ]) async {
    return FusionNavigatorDelegate.instance.push(routeName, routeArgs);
  }

  /// Replace a designated flutter page with a new flutter page in the current container.
  Future<T?> replace<T extends Object?>(
    String routeName, [
    Map<String, dynamic>? routeArgs,
    bool animated = false,
  ]) async {
    return FusionNavigatorDelegate.instance
        .replace(routeName, routeArgs, animated);
  }

  /// Pop in the current container.
  Future<void> pop<T extends Object?>([T? result]) async {
    return FusionNavigatorDelegate.instance.pop(result);
  }

  /// Pop in the current container.
  /// Can be used with [WillPopScope].
  Future<bool> maybePop<T extends Object?>([T? result]) async {
    return FusionNavigatorDelegate.instance.maybePop(result);
  }

  /// Remove a designated flutter page in all containers.
  Future<void> remove(String routeName) async {
    return FusionNavigatorDelegate.instance.remove(routeName);
  }

  /// Send a message to flutter side and native side.
  void sendMessage(String name, [Map<String, dynamic>? body]) {
    return FusionChannel.instance.sendMessage(name, body);
  }

  NavigatorState? get navigator =>
      FusionOverlayManager.instance.topRoute?.navigator;
}
