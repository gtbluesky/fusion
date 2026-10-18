import 'package:flutter/material.dart';
import '../container/fusion_overlay.dart';
import '../container/fusion_page.dart';
import '../navigator/fusion_navigator_delegate.dart';
import '../navigator/fusion_navigator_observer.dart';
import '../navigator/fusion_route_observer.dart';

class FusionContainer extends ChangeNotifier {
  FusionContainer(this.uniqueId, FusionPage page)
      : key = ValueKey<String>(uniqueId) {
    page.container = this;
    _pages.add(page);
  }

  FusionContainer.restore(this.uniqueId, List<FusionPage> pages)
      : key = ValueKey<String>(uniqueId) {
    for (final page in pages) {
      page.container = this;
    }
    _pages.addAll(pages);
  }

  final LocalKey key;

  final String uniqueId;

  bool isVisible = false;

  List<FusionPage> get pages => List.unmodifiable(_pages);

  List<FusionPageEntity> get pageEntities =>
      _pages.map((e) => e.pageEntity).toList();

  FusionPage? get topPage => _pages.lastOrNull;

  int get pageCount => _pages.length;

  final _pages = <FusionPage>[];

  NavigatorState? get navigator => _navKey.currentState;
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  Future<T?> push<T extends Object?>(FusionPage<T> page) {
    page.container = this;
    FusionOverlayManager.instance.containerRoutesMap[uniqueId]?.add(page.route);
    FusionRouteObserverManager.instance.didAdd(page.route);
    _pages.add(page);
    notifyListeners();
    return page.popped;
  }

  void pop<T extends Object?>([T? result]) {
    if (_pages.isEmpty) {
      return;
    }
    final page = _pages.removeLast();
    page.didComplete(result);
    final success = FusionOverlayManager.instance.containerRoutesMap[uniqueId]
            ?.remove(page.route) ??
        false;
    if (success) {
      FusionRouteObserverManager.instance.didRemove(page.route);
    }
    notifyListeners();
  }

  void remove(FusionPage page) {
    if (_pages.isEmpty) {
      return;
    }
    _pages.remove(page);
    page.didComplete(null);
    final result = FusionOverlayManager.instance.containerRoutesMap[uniqueId]
            ?.remove(page.route) ??
        false;
    if (result) {
      FusionRouteObserverManager.instance.didRemove(page.route);
    }
    notifyListeners();
  }

  void removeAll(List<FusionPage> pages) {
    if (_pages.isEmpty) {
      return;
    }
    for (final page in pages) {
      if (_pages.contains(page)) {
        _pages.remove(page);
        page.didComplete(null);
        final result = FusionOverlayManager
                .instance.containerRoutesMap[uniqueId]
                ?.remove(page.route) ??
            false;
        if (result) {
          FusionRouteObserverManager.instance.didRemove(page.route);
        }
      }
    }
    notifyListeners();
  }

  Future<T?> replace<T extends Object?>(FusionPage<T> page) {
    page.container = this;
    if (_pages.isNotEmpty) {
      _pages.removeLast().didComplete(null);
    }
    _pages.add(page);
    final routes = FusionOverlayManager.instance.containerRoutesMap[uniqueId];
    if (routes?.isNotEmpty == true) {
      final route = routes?.removeLast();
      if (route != null) {
        FusionRouteObserverManager.instance.didRemove(route);
      }
    }
    routes?.add(page.route);
    FusionRouteObserverManager.instance.didAdd(page.route);
    notifyListeners();
    return page.popped;
  }

  FusionPage? findPage(String routeName) {
    for (final page in pages.reversed) {
      if (page.pageEntity.name == routeName) {
        return page;
      }
    }
    return null;
  }
}

/// OverlayEntry对应的Widget
class FusionContainerWidget extends StatefulWidget {
  final FusionContainer container;

  FusionContainerWidget(this.container, {Key? key}) : super(key: container.key);

  @override
  State<FusionContainerWidget> createState() => _FusionContainerWidgetState();

  @override
  // ignore: invalid_override_of_non_virtual_member
  int get hashCode => container.uniqueId.hashCode;

  @override
  // ignore: invalid_override_of_non_virtual_member
  bool operator ==(Object other) {
    if (other is FusionContainerWidget) {
      return container.uniqueId == other.container.uniqueId;
    }
    return super == other;
  }
}

class _FusionContainerWidgetState extends State<FusionContainerWidget> {
  FusionContainer get container => widget.container;

  void _pop(FusionPage? page, dynamic result) {
    if (page == null || page != container.topPage) {
      return;
    }
    container.pop(result);
  }

  void _refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    container.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant FusionContainerWidget oldWidget) {
    if (oldWidget != widget) {
      oldWidget.container.removeListener(_refresh);
      container.addListener(_refresh);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return HeroControllerScope(
      controller: HeroController(),
      child: NavigatorExtension(
        key: container._navKey,
        pages: container.pages,
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }
          _pop(route.settings as FusionPage?, result);
          return true;
        },
        observers: [FusionNavigatorObserver()],
      ),
    );
  }

  @override
  void dispose() {
    container.removeListener(_refresh);
    super.dispose();
  }
}

class NavigatorExtension extends Navigator {
  const NavigatorExtension({
    Key? key,
    required List<Page<dynamic>> pages,
    PopPageCallback? onPopPage,
    List<NavigatorObserver> observers = const <NavigatorObserver>[],
  }) : super(
          key: key,
          pages: pages,
          onPopPage: onPopPage,
          observers: observers,
        );

  @override
  NavigatorState createState() {
    return NavigatorExtensionState();
  }
}

class NavigatorExtensionState extends NavigatorState {
  @override
  Future<T?> push<T extends Object?>(Route<T> route) {
    if (route is PopupRoute) {
      final topContainer = FusionOverlayManager.instance.topContainer();
      FusionOverlayManager.instance.containerRoutesMap[topContainer?.uniqueId]
          ?.add(route);
      FusionRouteObserverManager.instance.didAdd(route);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        super.push(route);
      });
      // ignore: invalid_null_aware_operator
      WidgetsBinding.instance?.scheduleFrame();
      return route.popped;
    }
    return super.push(route);
  }

  @override
  Future<T?> pushNamed<T extends Object?>(String routeName,
      {Object? arguments}) {
    if (arguments == null) {
      return FusionNavigatorDelegate.instance.push<T>(routeName);
    }
    if (arguments is Map<String, dynamic>) {
      return FusionNavigatorDelegate.instance.push<T>(routeName, arguments);
    }
    if (arguments is Map) {
      return FusionNavigatorDelegate.instance
          .push<T>(routeName, Map<String, dynamic>.from(arguments));
    } else {
      return FusionNavigatorDelegate.instance.push<T>(routeName);
    }
  }

  @override
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
      String routeName,
      {TO? result,
      Object? arguments}) {
    if (arguments == null) {
      return FusionNavigatorDelegate.instance.replace(routeName);
    }
    if (arguments is Map<String, dynamic>) {
      return FusionNavigatorDelegate.instance.replace(routeName, arguments);
    }
    if (arguments is Map) {
      return FusionNavigatorDelegate.instance
          .replace(routeName, Map<String, dynamic>.from(arguments));
    } else {
      return FusionNavigatorDelegate.instance.replace(routeName);
    }
  }

  @override
  void pop<T extends Object?>([T? result]) {
    final topRoute = FusionOverlayManager.instance.topRoute;
    if (topRoute is PageRoute) {
      FusionNavigatorDelegate.instance.pop<T>(result);
    } else if (topRoute is PopupRoute && this != topRoute.navigator) {
      // showDialog, useRootNavigator: true
      topRoute.navigator?.pop<T>(result);
    } else {
      if (topRoute is PopupRoute) {
        final topContainer = FusionOverlayManager.instance.topContainer();
        final result = FusionOverlayManager
                .instance.containerRoutesMap[topContainer?.uniqueId]
                ?.remove(topRoute) ??
            false;
        if (result) {
          FusionRouteObserverManager.instance.didRemove(topRoute);
        }
      }
      super.pop<T>(result);
    }
  }

  @override
  void removeRoute<T extends Object?>(Route<T> route, [T? result]) {
    if (route is PopupRoute) {
      final targetContainer =
          FusionOverlayManager.instance.findContainerByRoute(route);
      final result = FusionOverlayManager
              .instance.containerRoutesMap[targetContainer?.uniqueId]
              ?.remove(route) ??
          false;
      if (result) {
        FusionRouteObserverManager.instance.didRemove(route);
      }
    }
    super.removeRoute(route, result);
  }
}
