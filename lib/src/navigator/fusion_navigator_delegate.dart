import 'package:flutter/material.dart';
import 'package:fusion/src/app/fusion_app.dart';
import 'package:fusion/src/channel/fusion_channel.dart';
import 'package:fusion/src/constant/fusion_constant.dart';
import 'package:fusion/src/lifecycle/page_lifecycle.dart';
import 'package:fusion/src/navigator/fusion_navigator.dart';
import 'package:fusion/src/navigator/fusion_navigator_observer.dart';
import 'package:fusion/src/page/unknown_page.dart';
import 'package:fusion/src/route/fusion_page_route.dart';
import 'package:fusion/src/widget/fusion_will_pop_scope.dart';

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
    Map<String, dynamic>? pageInfo =
        await FusionChannel.instance.push(routeName, arguments);
    if (pageInfo == null) {
      return null;
    }
    final route = FusionPageRoute<T>(
      builder: (_) {
        FusionPageFactory? pageFactory =
            routeMap[routeName] ?? routeMap[kUnknownRoute];
        final page =
            pageFactory != null ? pageFactory(arguments) : const UnknownPage();
        return FusionWillPopScope(
          onWillPopResult: ([result]) async {
            FusionNavigator.instance.pop(result);
            return false;
          },
          child: page,
        );
      },
      settings: RouteSettings(
        name: routeName,
        arguments: arguments,
      ),
      home: pageInfo['home'],
    );
    pageInfo['route'] = route;
    _history.add(pageInfo);
    return _navigator.push(route);
  }

  void restore<T extends Object?>(Map<String, dynamic> pageInfo) async {
    String routeName = pageInfo['name'];
    Map<String, dynamic>? arguments = (pageInfo['arguments'] as Map?)?.cast();
    final route = FusionPageRoute<T>(
      builder: (_) {
        FusionPageFactory? pageFactory =
            routeMap[routeName] ?? routeMap[kUnknownRoute];
        final page =
        pageFactory != null ? pageFactory(arguments) : const UnknownPage();
        return FusionWillPopScope(
          onWillPopResult: ([result]) async {
            FusionNavigator.instance.pop(result);
            return false;
          },
          child: page,
        );
      },
      settings: RouteSettings(
        name: routeName,
        arguments: arguments,
      ),
      home: pageInfo['home'],
      restore: true,
    );
    pageInfo['route'] = route;
    _history.add(pageInfo);
    _navigator.push(route);
  }

  Future<void> replace(String routeName,
      [Map<String, dynamic>? arguments]) async {
    Map<String, dynamic>? newPageInfo =
        await FusionChannel.instance.replace(routeName, arguments);
    if (newPageInfo == null) {
      return;
    }
    final newRoute = FusionPageRoute(
      builder: (_) {
        FusionPageFactory? pageFactory =
            routeMap[routeName] ?? routeMap[kUnknownRoute];
        final page =
            pageFactory != null ? pageFactory(arguments) : const UnknownPage();
        return FusionWillPopScope(
          onWillPopResult: ([result]) async {
            FusionNavigator.instance.pop(result);
            return false;
          },
          child: page,
        );
      },
      settings: RouteSettings(
        name: routeName,
        arguments: arguments,
      ),
      home: newPageInfo['home'],
    );
    newPageInfo['route'] = newRoute;
    final oldPageInfo = _history.removeLast();
    final oldRoute = oldPageInfo['route'] as FusionPageRoute;
    _history.add(newPageInfo);
    if (oldRoute.tickerFuture == null) {
      _navigator.replace(
        oldRoute: oldRoute,
        newRoute: newRoute,
      );
    } else {
      oldRoute.tickerFuture?.whenCompleteOrCancel(() {
        _navigator.replace(
          oldRoute: oldRoute,
          newRoute: newRoute,
        );
      });
    }
  }

  Future<void> pop<T extends Object?>([T? result]) async {
    final route = PageLifecycleBinding.instance.topRoute;
    if (route is FusionPageRoute) {
      bool executable = await FusionChannel.instance.pop();
      if (!executable) {
        return;
      }
      _history.removeLast();
    }
    return _navigator.pop<T>(result);
  }

  Future<bool> maybePop<T extends Object?>([T? result]) async {
    final route = PageLifecycleBinding.instance.topRoute;
    RoutePopDisposition? disposition;
    if (route is FusionPageRoute) {
      disposition = await route.willPopResult(result);
    } else {
      disposition = await route.willPop();
    }
    switch (disposition) {
      case RoutePopDisposition.bubble:
        return false;
      case RoutePopDisposition.pop:
        pop(result);
        return true;
      case RoutePopDisposition.doNotPop:
        return true;
    }
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
    final index =
        _history.lastIndexWhere((element) => element['name'] == routeName);
    if (index < 0) {
      return;
    }
    final pageInfo = _history.removeAt(index);
    return _navigator.removeRoute(pageInfo['route']);
  }
}
