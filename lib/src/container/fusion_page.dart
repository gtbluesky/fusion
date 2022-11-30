import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fusion/src/constant/fusion_constant.dart';
import 'package:fusion/src/container/fusion_container.dart';
import 'package:fusion/src/data/fusion_data.dart';
import 'package:fusion/src/navigator/fusion_navigator_delegate.dart';
import 'package:fusion/src/page/unknown_page.dart';

// ignore: must_be_immutable
class FusionPage<T> extends Page<T> {
  late FusionContainer container;

  final FusionPageEntity pageEntity;

  late Route<T> _route;

  Route<T> get route => _route;

  bool _animated = true;

  set containerVisible(bool value) => container.isVisible = value;

  bool get isVisible => container.isVisible && container.topPage == this;

  FusionPage({LocalKey? key, name, arguments})
      : pageEntity = FusionPageEntity(name, arguments),
        super(key: key, name: name, arguments: arguments);

  static FusionPage<dynamic> createPage(
    String name, [
    Map<String, dynamic>? arguments,
    bool animated = true,
  ]) {
    final page = FusionPage(key: UniqueKey(), name: name, arguments: arguments);
    page._animated = animated;
    final routeMap = FusionNavigatorDelegate.instance.routeMap;
    var pageFactory = routeMap?[name];
    if (pageFactory != null) {
      final pageWidget = pageFactory(arguments);
      page._route = FusionPageRoute(page: page, child: pageWidget);
      return page;
    }
    final customRouteMap = FusionNavigatorDelegate.instance.customRouteMap;
    var pageCustomFactory = customRouteMap?[name];
    if (pageCustomFactory != null) {
      final pageRoute = pageCustomFactory(page);
      page._route = pageRoute;
      return page;
    }
    pageFactory = routeMap?[kUnknownRoute];
    if (pageFactory != null) {
      final pageWidget = pageFactory(arguments);
      page._route = FusionPageRoute(page: page, child: pageWidget);
      return page;
    }
    pageCustomFactory = customRouteMap?[kUnknownRoute];
    if (pageCustomFactory != null) {
      final pageRoute = pageCustomFactory(page);
      page._route = pageRoute;
      return page;
    }
    page._route = FusionPageRoute(page: page, child: const UnknownPage());
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
  Duration get transitionDuration =>
      ((settings as FusionPage?)?._animated == true)
          ? FusionData.transitionDuration
          : const Duration(seconds: 0);

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
