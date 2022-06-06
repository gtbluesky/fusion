import 'package:flutter/material.dart';
import 'package:fusion/src/app/fusion_app.dart';
import 'package:fusion/src/channel/fusion_channel.dart';
import 'package:fusion/src/constant/fusion_constant.dart';
import 'package:fusion/src/navigator/fusion_navigator.dart';
import 'package:fusion/src/navigator/fusion_navigator_observer.dart';
import 'package:fusion/src/page/unknown_page.dart';
import 'package:fusion/src/route/fusion_page_route.dart';

class FusionNavigatorDelegate {
  FusionNavigatorDelegate._();

  static final FusionNavigatorDelegate _instance = FusionNavigatorDelegate._();

  static FusionNavigatorDelegate get instance => _instance;

  NavigatorState get _navigator => FusionNavigatorObserver.instance.navigator!;

  late Map<String, FusionPageFactory> routeMap;

  final _history = <Map<String, dynamic>>[];

  bool isFlutterPage(String routeName) {
    return routeMap.containsKey(routeName);
  }

  Future<T?> push<T extends Object?>(
      String routeName, [
        Map<String, dynamic>? arguments,
      ]) async {
    Map<String, dynamic>? pageInfo = await FusionChannel.instance.push(routeName, arguments);
    if (pageInfo == null) {
      return null;
    }
    final route = FusionPageRoute<T>(
        builder: (_) {
          FusionPageFactory? pageFactory =
              routeMap[routeName] ?? routeMap[unknownRoute];
          final page = pageFactory != null
              ? pageFactory(arguments)
              : const UnknownPage();
          return WillPopScope(onWillPop: () async {
            FusionNavigator.instance.pop();
            return false;
          },
              child: page);
        },
        settings: RouteSettings(
          name: routeName,
          arguments: arguments,
        ),
        home: pageInfo['home']);
    pageInfo['route'] = route;
    _history.add(pageInfo);
    return _navigator.push(route);
  }

  Future<void> replace(String routeName, [Map<String, dynamic>? arguments]) async {
    Map<String, dynamic>? newPageInfo = await FusionChannel.instance.replace(routeName, arguments);
    if (newPageInfo == null) {
      return;
    }
    final route = FusionPageRoute(
        builder: (_) {
          FusionPageFactory? pageFactory =
              routeMap[routeName] ?? routeMap[unknownRoute];
          final page = pageFactory != null
              ? pageFactory(arguments)
              : const UnknownPage();
          return WillPopScope(onWillPop: () async {
            FusionNavigator.instance.pop();
            return false;
          },
              child: page);
        },
        settings: RouteSettings(
          name: routeName,
          arguments: arguments,
        ),
        home: newPageInfo['home']);
    newPageInfo['route'] = route;
    final oldPageInfo = _history.removeLast();
    _history.add(newPageInfo);
    return _navigator.replace(oldRoute: oldPageInfo['route'], newRoute: newPageInfo['route']);
  }

  Future<void> pop<T extends Object>([T? result]) async {
    bool executable = await FusionChannel.instance.pop();
    if (!executable) {
      return;
    }
    _history.removeLast();
    return _navigator.pop<T>(result);
  }

  Future<void> directPop() async {
    _history.removeLast();
    return _navigator.pop();
  }

  /// 右滑退出后更新路由栈
  Future<void> popHistory() async {
    bool executable = await FusionChannel.instance.pop();
    if (!executable) {
      return;
    }
    _history.removeLast();
  }

  Future<void> remove(String routeName) async {
    bool executable = await FusionChannel.instance.remove(routeName);
    if (!executable) {
      return;
    }
    final index = _history.lastIndexWhere((element) => element['name'] == routeName);
    if (index < 0) {
      return;
    }
    final pageInfo = _history.removeAt(index);
    return _navigator.removeRoute(pageInfo['route']);
  }
}