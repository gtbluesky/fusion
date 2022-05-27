import 'dart:async';

import 'package:flutter/material.dart';

import '../channel/fusion_channel.dart';
import '../constant/fusion_constant.dart';
import '../page/unknown_page.dart';
import '../route/fusion_page.dart';
import 'fusion_navigator.dart';
import 'fusion_navigator_observer.dart';

class FusionRouterDelegate extends RouterDelegate<Map<String, dynamic>>
    with ChangeNotifier {
  FusionRouterDelegate._();

  static final FusionRouterDelegate _instance = FusionRouterDelegate._();

  late Map<String, dynamic> _home;
  final _history = <Map<String, dynamic>>[];
  final _callback = <String, Completer<dynamic>>{};

  static FusionRouterDelegate get instance => _instance;

  GlobalKey<NavigatorState>? get navigatorKey => FusionNavigator.instance.key;

  final navigatorObserver = FusionNavigatorObserver();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: (route, result) {
        pop(result);
        return false;
      },
      pages: _buildHistoryPages(),
      observers: <NavigatorObserver>[navigatorObserver],
    );
  }

  List<Page> _buildHistoryPages() {
    if (currentConfiguration == null) return <Page>[];
    _history.forEach((element) {
      print('element=$element');
    });
    return _history.map((e) {
      final arguments = (e['arguments'] as Map?)?.cast<String, dynamic>();
      PageFactory? pageFactory = FusionNavigator.instance.routeMap[e['name']] ??
          (e['name'] == Navigator.defaultRouteName
              ? (_) => Container(
                    color: Colors.white,
                  )
              : FusionNavigator.instance.routeMap[unknownRoute]);
      final page =
          pageFactory != null ? pageFactory(arguments) : const UnknownPage();
      return FusionPage(
        child: page,
        name: e['name'],
        arguments: e['arguments'],
        isFirstPage: e['isFirstPage'] ?? false,
      );
    }).toList();
  }

  /// popRoute: 点击物理按键返回时被调用
  /// onPopPage: 点击 Flutter 自带导航栏左侧返回键或 iOS 右滑返回时被调用
  /// true: 表示自行处理
  /// false: 表示交由 Flutter 系统处理
  @override
  Future<bool> popRoute() async {
    await pop();
    return true;
  }

  @override
  Future<void> setNewRoutePath(Map<String, dynamic> configuration) async {
    _home = configuration;
    _history.add(_home);
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
    refreshHistory(history);
    _callback.remove(_history.last['uniqueId'])?.complete(result);
  }

  void refreshHistory(List<Map<String, dynamic>>? history) {
    _history.clear();
    _history.add(_home);
    history?.forEach((element) {
      _history.add(element);
    });
    notifyListeners();
  }
}
