import 'package:flutter/material.dart';

import '../channel/fusion_channel.dart';
import 'route_information_parser.dart';
import 'router_delegate.dart';

typedef PageFactory = Widget Function(Map<String, dynamic>? arguments);

class FusionNavigator {
  FusionNavigator._();

  static final FusionNavigator _instance = FusionNavigator._();

  static FusionNavigator get instance => _instance;

  final _key = GlobalKey<NavigatorState>();

  late FusionRouterDelegate routerDelegate;
  late FusionRouteInformationParser routeInformationParser;
  late Map<String, PageFactory> routeMap;

  GlobalKey<NavigatorState> get key => _key;

  bool isFlutterPage(String routeName) {
    return routeMap.containsKey(routeName);
  }

  Future<T?> push<T extends Object?>(String routeName,
      [Map<String, dynamic>? arguments]) {
    return routerDelegate.push(routeName, arguments);
  }

  Future<void> replace(String routeName,
      [Map<String, dynamic>? arguments]) {
    return routerDelegate.replace(routeName, arguments);
  }

  Future<void> pop<T extends Object>([T? result]) {
    return routerDelegate.pop(result);
  }

  Future<void> remove(String routeName, [bool all = false]) {
    return routerDelegate.remove(routeName, all);
  }

  void sendMessage(String msgName, [Map<String, dynamic>? msgBody]) {
    return FusionChannel.instance.sendMessage(msgName, msgBody);
  }
}
