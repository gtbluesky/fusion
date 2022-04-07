import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fusion/channel/fusion_channel.dart';
import 'package:fusion/navigator/fusion_navigator.dart';

class FusionRouterDelegate extends RouterDelegate<RouteSettings>
    with ChangeNotifier {
  final _history = <RouteSettings>[];
  final _callback = <RouteSettings, Completer<dynamic>>{};
  bool _childMode = false;

  GlobalKey<NavigatorState>? get navigatorKey => FusionNavigator.instance.key;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        if (kDebugMode) {
          print('onPopPage');
        }
        pop(result);
        return true;
      },
      pages: _buildHistoryPages(),
    );
  }

  List<Page> _buildHistoryPages() {
    if (currentConfiguration == null) return <Page>[];
    return _history
        .map((e) => MaterialPage(
            child: FusionNavigator.instance
                .routeMap[e.name]!(e.arguments as Map<String, dynamic>)))
        .toList();
  }

  /// popRoute: 点击物理按键返回时被调用
  /// onPopPage: 点击 Flutter 自带导航栏左侧返回键时被调用
  /// true: 表示自行处理
  /// false: 表示交由 Flutter 系统处理
  @override
  Future<bool> popRoute() async {
    if (kDebugMode) {
      print('popRoute');
    }
    await pop();
    return true;
  }

  @override
  Future<void> setNewRoutePath(RouteSettings configuration) async {
    if (configuration.arguments is Map<String, dynamic>) {
      final arguments = configuration.arguments as Map<String, dynamic>;
      _childMode = arguments['fusion_child_mode'] == 'true';
    }
    if (kDebugMode) {
      print('_childMode=$_childMode');
    }
    await _pushHistory(configuration);
  }

  @override
  RouteSettings? get currentConfiguration {
    if (_history.isEmpty) {
      return null;
    }
    return _history.last;
  }

  Future<void> _pushHistory(RouteSettings routeSettings) async {
    _history.add(routeSettings);
    await FusionChannel.push(routeSettings.name!, routeSettings.arguments);
    notifyListeners();
  }

  Future<T?> push<T extends Object?>(
    String routeName, [
    Map<String, dynamic>? routeArguments,
  ]) async {
    final completer = Completer<T>();
    final arguments = routeArguments ?? {};
    if (FusionNavigator.instance.isFlutterPage(routeName)) {
      if (_childMode) {
        arguments['fusion_push_mode'] = 1;
        await FusionChannel.push(routeName, arguments);
      } else {
        _callback[_history.last] = completer;
        await _pushHistory(
            RouteSettings(name: routeName, arguments: arguments));
      }
    } else {
      arguments['fusion_push_mode'] = 0;
      await FusionChannel.push(routeName, arguments);
    }
    return completer.future;
  }

  Future<void> pop<T extends Object>([T? result]) async {
    if (kDebugMode) {
      print('_history.length=${_history.length}');
    }
    if (_history.length == 1) {
      await FusionChannel.pop();
      return;
    }
    _history.removeLast();
    _callback[_history.last]?.complete(result);
    await FusionChannel.pop();
    notifyListeners();
  }
}
