import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fusion/channel/fusion_channel.dart';
import 'package:fusion/navigator/fusion_navigator.dart';
import 'package:fusion/navigator/fusion_navigator_observer.dart';

class FusionRouterDelegate extends RouterDelegate<Map<String, dynamic>>
    with ChangeNotifier {
  final _history = <Map<String, dynamic>>[];
  final _callback = <String, Completer<dynamic>>{};

  GlobalKey<NavigatorState>? get navigatorKey => FusionNavigator.instance.key;

  final navigatorObserver = FusionNavigatorObserver();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        pop(result);
        return true;
      },
      pages: _buildHistoryPages(),
      observers: <NavigatorObserver>[navigatorObserver],
    );
  }

  List<Page> _buildHistoryPages() {
    if (currentConfiguration == null) return <Page>[];
    return _history.map((e) {
      final arguments = (e["arguments"] as Map?)?.cast<String, dynamic>();
      return MaterialPage(
          child: FusionNavigator.instance.routeMap[e['name']]!(arguments),
          name: e['name'],
          arguments: e["arguments"]);
    }).toList();
  }

  /// popRoute: 点击物理按键返回时被调用
  /// onPopPage: 点击 Flutter 自带导航栏左侧返回键时被调用
  /// true: 表示自行处理
  /// false: 表示交由 Flutter 系统处理
  @override
  Future<bool> popRoute() async {
    await pop();
    return true;
  }

  @override
  Future<void> setNewRoutePath(Map<String, dynamic> configuration) async {
    _history.add(configuration);
    notifyListeners();
  }

  @override
  Map<String, dynamic>? get currentConfiguration {
    if (_history.isEmpty) {
      return null;
    }
    return _history.last;
  }

  Future<T?> push<T extends Object?>(
    String routeName, [
    Map<String, dynamic>? routeArguments,
  ]) async {
    final history = await FusionChannel.push(routeName, routeArguments ?? {});
    if (history != null && history.isNotEmpty) {
      final completer = Completer<T>();
      _callback[_history.last['uniqueId']] = completer;
      refreshHistory(history);
      return completer.future;
    } else {
      return null;
    }
  }

  Future<void> pop<T extends Object>([T? result]) async {
    final history = await FusionChannel.pop();
    if (history != null && history.isNotEmpty) {
      refreshHistory(history);
    }
    _callback.remove(_history.last['uniqueId'])?.complete(result);
  }

  void refreshHistory(List<Map<String, dynamic>> history) {
    _history.clear();
    _history.addAll(history);
    notifyListeners();
  }
}
