import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fusion/src/app/fusion_app.dart';
import 'package:fusion/src/container/fusion_container.dart';
import 'package:fusion/src/data/fusion_data.dart';
import 'package:fusion/src/navigator/fusion_navigator_delegate.dart';
import 'package:fusion/src/constant/fusion_constant.dart';
import 'package:fusion/src/page/unknown_page.dart';

// ignore: must_be_immutable
class FusionPage<T> extends Page<T> {
  late FusionContainer container;

  final FusionPageEntity pageEntity;

  late Route<T> _route;

  Route<T> get route => _route;

  set containerVisible(bool value) => container.isVisible = value;

  bool get isVisible => container.isVisible && container.topPage == this;

  FusionPage({LocalKey? key, name, arguments})
      : pageEntity = FusionPageEntity(name, arguments),
        super(key: key, name: name, arguments: arguments);

  static FusionPage<T> createPage<T>(
    String name, [
    Map<String, dynamic>? arguments,
  ]) {
    final page =
        FusionPage<T>(key: UniqueKey(), name: name, arguments: arguments);
    final routeMap = FusionNavigatorDelegate.instance.routeMap;
    FusionPageFactory? pageFactory = routeMap[name] ?? routeMap[kUnknownRoute];
    final pageWidget =
        pageFactory != null ? pageFactory(arguments) : const UnknownPage();
    /// TODO 支持其他route
    page._route = FusionPageRoute(page: page, child: pageWidget);
    return page;
  }

  @override
  Route<T> createRoute(BuildContext context) {
    return _route;
  }

  Future<T?> get popped => _popCompleter.future;
  final Completer<T?> _popCompleter = Completer<T?>();

  void didComplete(T? result) {
    if (_popCompleter.isCompleted) {
      return;
    }
    _popCompleter.complete(result);
  }
}

class FusionPageEntity {
  final uniqueId = 'page_${DateTime.now().millisecondsSinceEpoch}';
  final String name;
  final Map<String, dynamic>? arguments;

  FusionPageEntity(this.name, this.arguments);
}

class FusionPageRoute<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin {
  FusionPageRoute({
    required FusionPage<T> page,
    required this.child,
  }) : super(settings: page) {
    assert(opaque);
  }

  final Widget child;

  @override
  Duration get transitionDuration => FusionData.transitionDuration;

  @override
  Duration get reverseTransitionDuration =>
      FusionData.reverseTransitionDuration;

  @override
  Widget buildContent(BuildContext context) {
    return child;
  }

  @override
  bool get maintainState => true;

  @override
  bool get fullscreenDialog => false;
}
