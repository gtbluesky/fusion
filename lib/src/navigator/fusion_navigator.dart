import 'package:flutter/material.dart';

import '../channel/fusion_channel.dart';
import 'route_information_parser.dart';
import 'router_delegate.dart';

typedef PageFactory = Widget Function(Map<String, dynamic>? arguments);

class FusionNavigator {
  FusionNavigator._();

  static final FusionNavigator _instance = FusionNavigator._();
  final _key = GlobalKey<NavigatorState>();

  late FusionRouterDelegate routerDelegate;
  late FusionRouteInformationParser routeInformationParser;
  late Map<String, PageFactory> routeMap;

  static FusionNavigator get instance => _instance;

  GlobalKey<NavigatorState> get key => _key;

  bool isFlutterPage(String routeName) {
    return routeMap.containsKey(routeName);
  }

  Future<T?> push<T extends Object?>(
    String routeName, {
    Map<String, dynamic>? arguments,
  }) async {
    return await routerDelegate.push(routeName, arguments);
  }

  Future<void> pop<T extends Object>([T? result]) async {
    return await routerDelegate.pop(result);
  }

  void sendMessage(String msgName, {Map<String, dynamic>? msgBody}) {
    return FusionChannel.sendMessage(msgName, msgBody: msgBody);
  }
}
