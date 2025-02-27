import 'package:flutter/material.dart';
import '../app/fusion_app.dart';
import '../channel/fusion_channel.dart';
import '../container/fusion_container.dart';
import '../container/fusion_overlay.dart';
import '../container/fusion_page.dart';
import '../fusion.dart';
import '../interceptor/fusion_interceptor.dart';
import '../lifecycle/fusion_page_lifecycle.dart';
import 'fusion_navigator.dart';
import 'fusion_navigator_observer.dart';

class FusionNavigatorDelegate {
  FusionNavigatorDelegate._();

  static final FusionNavigatorDelegate _instance = FusionNavigatorDelegate._();

  static FusionNavigatorDelegate get instance => _instance;

  Map<String, FusionPageFactory>? routeMap;

  Map<String, FusionPageCustomFactory>? customRouteMap;

  bool _isFlutterPage(String routeName) {
    if (routeMap == null && customRouteMap == null) {
      return true;
    }
    return routeMap?.containsKey(routeName) == true ||
        customRouteMap?.containsKey(routeName) == true;
  }

  Future<T?> push<T extends Object?>(
    String routeName, [
    Map<String, dynamic>? args,
    FusionRouteType type = FusionRouteType.adaption,
  ]) async {
    final option =
        FusionInterceptorOption(routeName: routeName, args: args, type: type);
    var state = InterceptorState<FusionInterceptorOption>(option);
    for (final interceptor in Fusion.instance.interceptors) {
      final handler = InterceptorHandler();
      interceptor.onPush(state.data, handler);
      state = handler.state;
      if (handler.state.type == InterceptorResultType.resolve) {
        break;
      } else if (handler.state.type == InterceptorResultType.reject) {
        return null;
      }
    }
    if (state.data.routeName != null) {
      routeName = state.data.routeName!;
    }
    if (state.data.args != null) {
      args = state.data.args!;
    }
    if (state.data.type != null) {
      type = state.data.type!;
    }
    switch (type) {
      case FusionRouteType.flutter:
        return _push<T>(routeName, args);
      case FusionRouteType.flutterWithContainer:
      case FusionRouteType.native:
        FusionChannel.instance.push(routeName, args, type);
        return null;
      case FusionRouteType.adaption:
        if (_isFlutterPage(routeName)) {
          if (FusionOverlayManager.instance.topContainer()?.isVisible == true) {
            return _push<T>(routeName, args);
          } else {
            await FusionChannel.instance
                .push(routeName, args, FusionRouteType.flutterWithContainer);
            return null;
          }
        } else {
          await FusionChannel.instance
              .push(routeName, args, FusionRouteType.native);
          return null;
        }
    }
  }

  Future<T?> _push<T extends Object?>(
    String routeName, [
    Map<String, dynamic>? args,
  ]) async {
    FusionContainer? container = FusionOverlayManager.instance.topContainer();
    if (container == null) {
      return null;
    }
    Future.microtask(() {
      // Sync
      FusionChannel.instance.sync(container.uniqueId, container.pageEntities);
    });
    final page = FusionPage.createPage(routeName, args);
    // Page's Visibility Change
    _handlePageInvisible(FusionOverlayManager.instance.topPageRoute);
    _handlePageVisible(page.route, isFirstTime: true);
    return await container.push<dynamic>(page);
  }

  Future<T?> pushAndClear<T extends Object?>(
    String routeName, [
    Map<String, dynamic>? args,
  ]) async {
    // push a new page in top container
    final result = _push<T>(routeName, args);
    final containers =
        FusionOverlayManager.instance.containers.reversed.toList();
    // remove other pages in top container
    if (containers.isNotEmpty) {
      final topContainer = containers.removeAt(0);
      final pages = topContainer.pages.reversed.toList();
      if (pages.isNotEmpty) {
        pages.removeAt(0);
        topContainer.removeAll(pages);
      }
      FusionChannel.instance
          .sync(topContainer.uniqueId, topContainer.pageEntities);
    }
    // remove root dialogs
    for (final route in FusionOverlayManager.instance.rootRoutes) {
      route.navigator?.removeRoute(route);
    }
    // remove other container with pages and dialogs
    for (final container in containers) {
      _handleRouterObserver(container.uniqueId, isPop: false);
      await FusionChannel.instance.destroy(container.uniqueId);
    }
    return result;
  }

  Future<T?> replace<T extends Object?>(
    String routeName, [
    Map<String, dynamic>? args,
    bool animated = false,
  ]) async {
    final topPageRoute = FusionOverlayManager.instance.topPageRoute;
    FusionContainer? container = FusionOverlayManager.instance.topContainer();
    if (container == null) {
      return null;
    }
    Future.microtask(() {
      FusionChannel.instance.sync(container.uniqueId, container.pageEntities);
    });
    final page = FusionPage.createPage(routeName, args, animated);
    // Page's Visibility Change
    _handlePageInvisible(topPageRoute);
    _handlePageVisible(page.route, isFirstTime: true);
    return await container.replace<dynamic>(page);
  }

  Future<void> pop<T extends Object?>([T? result]) async {
    final topRoute = FusionOverlayManager.instance.topRoute;
    if (topRoute is! PageRoute) {
      topRoute?.navigator?.pop<T>(result);
      return;
    }
    FusionContainer? container = FusionOverlayManager.instance.topContainer();
    if (container == null) {
      return;
    }
    final option = FusionInterceptorOption(routeName: container.topPage?.name);
    var state = InterceptorState<FusionInterceptorOption>(option);
    for (final interceptor in Fusion.instance.interceptors) {
      final handler = InterceptorHandler();
      interceptor.onPop(state.data, handler);
      state = handler.state;
      if (handler.state.type == InterceptorResultType.resolve) {
        break;
      } else if (handler.state.type == InterceptorResultType.reject) {
        return;
      }
    }
    if (container.pageCount > 1) {
      // Page's Visibility Change
      _handlePageInvisible(topRoute);
      _handlePageVisible(FusionOverlayManager.instance.nextPageRoute);
      container.pop(result);
      FusionChannel.instance.sync(container.uniqueId, container.pageEntities);
    } else {
      _handleRouterObserver(container.uniqueId, isPop: true);
      await FusionChannel.instance.destroy(container.uniqueId);
    }
  }

  void _handleRouterObserver(String uniqueId, {required bool isPop}) {
    FusionOverlayManager.instance.containerRoutesMap
        .remove(uniqueId)
        ?.forEach((route) {
      FusionNavigatorObserverManager.instance.navigatorObservers
          ?.forEach((observer) {
        if (isPop) {
          observer.didPop(route, null);
        } else {
          observer.didRemove(route, null);
        }
      });
    });
  }

  Future<bool> maybePop<T extends Object?>([T? result]) async {
    final route = FusionOverlayManager.instance.topRoute;
    RoutePopDisposition? disposition = await route?.willPop();
    switch (disposition) {
      case RoutePopDisposition.bubble:
        pop<T>(result);
        return false;
      case RoutePopDisposition.pop:
        pop<T>(result);
        return true;
      case RoutePopDisposition.doNotPop:
        return true;
      default:
        return false;
    }
  }

  Future<void> popUntil(String routeName) async {
    if (routeName.isEmpty) {
      return;
    }
    bool hasTargetRoute = false;
    final allRoutes = [
      ...FusionOverlayManager.instance.rootRoutes,
      ...FusionOverlayManager.instance.containerRoutes
    ];
    for (final route in allRoutes) {
      if (route.settings.name == routeName) {
        hasTargetRoute = true;
        break;
      }
    }
    if (!hasTargetRoute) {
      return;
    }
    // root dialogs
    final rootRoutes =
        List<Route>.from(FusionOverlayManager.instance.rootRoutes.reversed);
    for (var route in rootRoutes) {
      if (route.settings.name == routeName) {
        return;
      }
      route.navigator?.pop();
    }
    if (rootRoutes.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    FusionContainer? targetContainer =
        FusionOverlayManager.instance.findContainerByRouteName(routeName);
    if (targetContainer == null) {
      return;
    }
    var routesInTargetContainer = FusionOverlayManager
        .instance.containerRoutesMap[targetContainer.uniqueId];
    if (routesInTargetContainer == null) {
      return;
    }
    routesInTargetContainer = List.from(routesInTargetContainer);
    final topPageRoute = FusionOverlayManager.instance.topPageRoute;
    bool hasPageVisibilityChange = false;
    // other containers with pages
    for (final container in FusionOverlayManager.instance.containers.reversed) {
      if (container == targetContainer) {
        break;
      }
      hasPageVisibilityChange = true;
      _handleRouterObserver(container.uniqueId, isPop: true);
      await FusionChannel.instance.destroy(container.uniqueId);
    }
    // target container's pages
    for (var i = targetContainer.pages.length - 1; i >= 0; --i) {
      final page = targetContainer.pages[i];
      final route = page.route;
      if (route.settings.name == routeName) {
        break;
      }
      if (route is PageRoute) {
        hasPageVisibilityChange = true;
        targetContainer.pop();
        await Future.delayed(const Duration(milliseconds: 50));
      } else {
        route.navigator?.pop();
      }
      routesInTargetContainer.remove(route);
    }
    // await Future.delayed(const Duration(milliseconds: 50));
    if (hasPageVisibilityChange) {
      // final topPage = FusionOverlayManager.instance.findPage(topPageRoute);
      _handlePageInvisible(topPageRoute);
      routesInTargetContainer.remove(topPageRoute);
      for (var route in routesInTargetContainer.reversed) {
        if (route is PageRoute) {
          _handlePageVisible(route);
          break;
        }
      }
    }
    Future.microtask(() {
      FusionChannel.instance
          .sync(targetContainer.uniqueId, targetContainer.pageEntities);
    });
  }

  Future<void> remove(String routeName) async {
    for (final route in FusionOverlayManager.instance.rootRoutes.reversed) {
      if (route.settings.name == routeName) {
        route.navigator?.removeRoute(route);
        return;
      }
    }
    FusionContainer? container =
        FusionOverlayManager.instance.findContainerByRouteName(routeName);
    if (container == null) {
      // not found
      return;
    }
    final page = container.findPage(routeName);
    // target route is dialog
    if (page == null) {
      final routes =
          FusionOverlayManager.instance.containerRoutesMap[container.uniqueId];
      if (routes == null) {
        return;
      }
      for (final route in routes.reversed) {
        if (route.settings.name == routeName) {
          route.navigator?.removeRoute(route);
          return;
        }
      }
      return;
    }
    // target route is page
    if (container.pageCount > 1) {
      final topPageRoute = FusionOverlayManager.instance.topPageRoute;
      if (page.route == topPageRoute) {
        // Page's Visibility Change
        _handlePageInvisible(topPageRoute);
        _handlePageVisible(FusionOverlayManager.instance.nextPageRoute);
      }
      container.remove(page);
      FusionChannel.instance.sync(container.uniqueId, container.pageEntities);
    } else {
      _handleRouterObserver(container.uniqueId, isPop: false);
      await FusionChannel.instance.destroy(container.uniqueId);
    }
  }

  bool hasRouteByName(String routeName) {
    for (var route in FusionOverlayManager.instance.rootRoutes) {
      if (route.settings.name == routeName) {
        return true;
      }
    }
    for (var route in FusionOverlayManager.instance.containerRoutes) {
      if (route.settings.name == routeName) {
        return true;
      }
    }
    return false;
  }

  bool hasPageByName(String routeName) {
    final page = FusionOverlayManager.instance.findPageByName(routeName);
    return page != null;
  }

  String get topPageRouteName {
    FusionPage? page = FusionOverlayManager.instance.topContainer()?.topPage;
    return page?.name ?? '';
  }

  void create(
    String uniqueId,
    String routeName, [
    Map<String, dynamic>? args,
  ]) {
    // Create a container and a page
    FusionPage page = FusionPage.createPage(routeName, args);
    FusionContainer container = FusionContainer(uniqueId, page);
    // Insert an overlay into the container
    FusionOverlayManager.instance.add(container);
    // Sync
    FusionChannel.instance.sync(uniqueId, container.pageEntities);
  }

  /// APP Restore
  void restore(String uniqueId, List<Map<String, dynamic>> history) {
    if (history.isEmpty) return;
    // Restore the container and pages
    final pages = <FusionPage>[];
    for (final map in history) {
      String routeName = map['name'];
      final args = (map['args'] as Map?)?.cast<String, dynamic>();
      final page = FusionPage.createPage(routeName, args);
      pages.add(page);
    }
    final container = FusionContainer.restore(uniqueId, pages);
    // Page's Visibility Change
    _handlePageInvisible(FusionOverlayManager.instance.topPageRoute);
    _handlePageVisible(pages.last.route, isFirstTime: true);
    // Insert overlay into the container
    FusionOverlayManager.instance.add(container);
    FusionChannel.instance.sync(container.uniqueId, container.pageEntities);
  }

  /// Hot Restart Restore
  void restoreAfterHotRestart() async {
    // Restore containers and pages
    final list = await FusionChannel.instance.restore();
    if (list.isEmpty) {
      return;
    }
    final containers = <FusionContainer>[];
    for (final containerMap in list) {
      String uniqueId = containerMap['uniqueId'];
      List history = containerMap['history'];
      final pages = <FusionPage>[];
      for (final map in history) {
        String routeName = map['name'];
        final args = (map['args'] as Map?)?.cast<String, dynamic>();
        final page = FusionPage.createPage(routeName, args);
        pages.add(page);
      }
      if (pages.isEmpty) {
        continue;
      }
      final container = FusionContainer.restore(uniqueId, pages);
      containers.add(container);
    }
    if (containers.isEmpty) {
      return;
    }
    FusionOverlayManager.instance.restore(containers);
    // Page's Visibility Change
    final page = containers.last.topPage;
    page?.containerVisible = true;
    _handlePageVisible(page?.route, isFirstTime: true);
  }

  void _handlePageVisible(
    Route? route, {
    bool isFirstTime = false,
  }) {
    if (route is! PageRoute) {
      return;
    }
    Future.microtask(() {
      // FusionPage? page = FusionOverlayManager.instance.findPage(route);
      // if (page == null) return;
      FusionPageLifecycleManager.instance
          .dispatchPageVisibleEvent(route, isFirstTime: isFirstTime);
    });
  }

  void _handlePageInvisible(Route? route) {
    if (route is! PageRoute) {
      return;
    }
    // FusionPage? page = FusionOverlayManager.instance.findPage(route);
    // if (page == null) return;
    FusionPageLifecycleManager.instance.dispatchPageInvisibleEvent(route);
  }
}
