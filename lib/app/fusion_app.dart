import 'package:flutter/material.dart';
import 'package:fusion/navigator/fusion_navigator.dart';
import 'package:fusion/navigator/route_information_parser.dart';
import 'package:fusion/navigator/router_delegate.dart';

class FusionApp extends StatelessWidget {
  FusionApp(
    Map<String, PageFactory> routeMap, {
    Key? key,
  }) : super(key: key) {
    FusionNavigator.instance.routeInformationParser =
        FusionRouteInformationParser();
    FusionNavigator.instance.routerDelegate = FusionRouterDelegate();
    FusionNavigator.instance.routeMap = routeMap;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        routeInformationParser: FusionNavigator.instance.routeInformationParser,
        routerDelegate: FusionNavigator.instance.routerDelegate);
  }
}
