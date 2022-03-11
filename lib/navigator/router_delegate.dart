import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fusion/channel/fusion_channel.dart';
import 'package:fusion/navigator/fusion_navigator.dart';

class FusionRouterDelegate extends RouterDelegate<RouteSettings>
    with ChangeNotifier {
  final _history = <RouteSettings>[];
  final _callback = <RouteSettings, Completer<dynamic>>{};

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
        if (_canPop()) {
          pop(result);
          return true;
        }
        return false;
      },
      pages: _buildHistoryPages(),
    );
  }

  bool _canPop() {
    return _history.length > 1;
  }

  List<Page> _buildHistoryPages() {
    if (currentConfiguration == null) return <Page>[];
    return _history
        .map((e) => MaterialPage(
            child: FusionNavigator.instance
                .routeMap[e.name]!(e.arguments as Map<String, dynamic>)))
        .toList();
  }

  @override
  Future<bool> popRoute() async {
    if (kDebugMode) {
      print('popRoute');
    }
    if (!_canPop()) {
      return SynchronousFuture(false);
    }
    await pop();
    return true;
  }

  @override
  Future<void> setNewRoutePath(RouteSettings configuration) async {
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
    await FusionChannel.push(routeSettings.name!, {'flutter': 'flutter'});
    notifyListeners();
  }

  Future<T?> push<T extends Object?>(
    String routeName, {
    Map<String, dynamic>? arguments,
  }) async {
    final completer = Completer<T>();
    if (FusionNavigator.instance.isFlutterPage(routeName)) {
      _callback[_history.last] = completer;
      await _pushHistory(RouteSettings(name: routeName, arguments: arguments));
    } else {
      await FusionChannel.push(routeName, arguments);
    }
    return completer.future;
  }

  Future<void> pop<T extends Object>([T? result]) async {
    _history.removeLast();
    _callback[_history.last]?.complete(result);
    await FusionChannel.pop();
    notifyListeners();
  }
}
