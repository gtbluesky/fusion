import 'package:flutter/material.dart';
import 'package:fusion/src/channel/fusion_channel.dart';
import 'package:fusion/src/container/fusion_overlay.dart';
import 'package:fusion/src/navigator/fusion_navigator_delegate.dart';

class FusionNavigator {
  FusionNavigator._();

  static final FusionNavigator _instance = FusionNavigator._();

  static FusionNavigator get instance => _instance;

  Future open(
    String routeName, [
    Map<String, dynamic>? routeArguments,
  ]) {
    return FusionChannel.instance.open(routeName, routeArguments);
  }

  Future<T?> push<T extends Object?>(
    String routeName, [
    Map<String, dynamic>? routeArguments,
  ]) async {
    return FusionNavigatorDelegate.instance.push(routeName, routeArguments);
  }

  Future<T?> replace<T extends Object?>(
    String routeName, [
    Map<String, dynamic>? routeArguments,
    bool animated = false,
  ]) async {
    return FusionNavigatorDelegate.instance.replace(routeName, routeArguments, animated);
  }

  Future<void> pop<T extends Object?>([T? result]) async {
    return FusionNavigatorDelegate.instance.pop(result);
  }

  Future<bool> maybePop<T extends Object?>([T? result]) async {
    return FusionNavigatorDelegate.instance.maybePop(result);
  }

  Future<void> remove(String routeName) async {
    return FusionNavigatorDelegate.instance.remove(routeName);
  }

  void sendMessage(String name, [Map<String, dynamic>? body]) {
    return FusionChannel.instance.sendMessage(name, body);
  }

  NavigatorState? get navigator =>
      FusionOverlayManager.instance.topRoute?.navigator;
}
