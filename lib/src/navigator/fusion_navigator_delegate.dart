import 'package:flutter/material.dart';
import 'package:fusion/src/app/fusion_app.dart';
import 'package:fusion/src/channel/fusion_channel.dart';
import 'package:fusion/src/container/fusion_container.dart';
import 'package:fusion/src/container/fusion_overlay.dart';
import 'package:fusion/src/container/fusion_page.dart';
import 'package:fusion/src/lifecycle/fusion_page_lifecycle.dart';

class FusionNavigatorDelegate {
  FusionNavigatorDelegate._();

  static final FusionNavigatorDelegate _instance = FusionNavigatorDelegate._();

  static FusionNavigatorDelegate get instance => _instance;

  Map<String, FusionPageFactory>? routeMap;

  Map<String, FusionPageCustomFactory>? customRouteMap;

  bool isFlutterPage(String routeName) {
    return routeMap?.containsKey(routeName) == true ||
        customRouteMap?.containsKey(routeName) == true;
  }

  void open(
    String uniqueId,
    String routeName, [
    Map<String, dynamic>? args,
  ]) {
    /// Create a container and a page
    FusionPage page = FusionPage.createPage(routeName, args);
    FusionContainer container = FusionContainer(uniqueId, page);

    /// Insert an overlay into the container
    FusionOverlayManager.instance.add(container);

    /// Sync
    FusionChannel.instance.sync(uniqueId, container.pageEntities);
  }

  Future<T?> push<T extends Object?>(
    String routeName, [
    Map<String, dynamic>? args,
  ]) async {
    if (isFlutterPage(routeName)) {
      FusionContainer? container = FusionOverlayManager.instance.topContainer();
      if (container == null) {
        return null;
      }
      Future.microtask(() {
        /// Sync
        FusionChannel.instance.sync(container.uniqueId, container.pageEntities);
      });
      final page = FusionPage.createPage(routeName, args);

      /// Page's Visibility Change
      final previousRoute = FusionOverlayManager.instance.topRoute;
      _handlePageInvisible(previousRoute);
      _handlePageVisible(page.route, isFirstTime: true);
      return await container.push<dynamic>(page);
    } else {
      /// Notify native's pushNativeRoute
      FusionChannel.instance.push(routeName, args);
      return null;
    }
  }

  Future<T?> replace<T extends Object?>(
    String routeName, [
    Map<String, dynamic>? args,
    bool animated = false,
  ]) async {
    final topRoute = FusionOverlayManager.instance.topRoute;
    if (topRoute is! PageRoute) {
      return null;
    }
    FusionContainer? container = FusionOverlayManager.instance.topContainer();
    if (container == null) {
      return null;
    }
    Future.microtask(() {
      FusionChannel.instance.sync(container.uniqueId, container.pageEntities);
    });
    final page = FusionPage.createPage(routeName, args, animated);

    /// Page's Visibility Change
    final oldRoute = topRoute;
    final newRoute = page.route;
    _handlePageInvisible(oldRoute);
    _handlePageVisible(newRoute);
    return await container.replace<dynamic>(page);
  }

  Future<void> pop<T extends Object?>([T? result]) async {
    final topRoute = FusionOverlayManager.instance.topRoute;
    if (topRoute is! PageRoute) {
      topRoute?.navigator?.pop(result);
      return;
    }
    FusionContainer? container = FusionOverlayManager.instance.topContainer();
    if (container == null) {
      return;
    }
    if (container.pageCount > 1) {
      /// Page's Visibility Change
      final route = topRoute;
      final previousRoute = FusionOverlayManager.instance.nextRoute;
      _handlePageInvisible(route);
      _handlePageVisible(previousRoute);
      container.pop(result);
      FusionChannel.instance.sync(container.uniqueId, container.pageEntities);
    } else {
      FusionChannel.instance.destroy(container.uniqueId);
    }
  }

  Future<bool> maybePop<T extends Object?>([T? result]) async {
    final route = FusionOverlayManager.instance.topRoute;
    RoutePopDisposition? disposition = await route?.willPop();
    switch (disposition) {
      case RoutePopDisposition.bubble:
        pop(result);
        return false;
      case RoutePopDisposition.pop:
        pop(result);
        return true;
      case RoutePopDisposition.doNotPop:
        return true;
      default:
        return false;
    }
  }

  Future<void> remove(String routeName) async {
    FusionContainer? container =
        FusionOverlayManager.instance.findContainerByPage(routeName);
    if (container == null) {
      return;
    }
    if (container.pageCount > 1) {
      final page = container.findPage(routeName);
      if (page == null) {
        return;
      }
      final topRoute = FusionOverlayManager.instance.topRoute;
      if (page.route == topRoute) {
        /// Page's Visibility Change
        final route = topRoute;
        final previousRoute = FusionOverlayManager.instance.nextRoute;
        _handlePageInvisible(route);
        _handlePageVisible(previousRoute);
      }
      container.remove(page);
      FusionChannel.instance.sync(container.uniqueId, container.pageEntities);
    } else {
      FusionChannel.instance.destroy(container.uniqueId);
    }
  }

  /// APP Restore
  void restore(String uniqueId, List<Map<String, dynamic>> history) {
    if (history.isEmpty) return;

    /// Restore the container and pages
    final pages = <FusionPage>[];
    for (final map in history) {
      String routeName = map['name'];
      final args = (map['args'] as Map?)?.cast<String, dynamic>();
      final page = FusionPage.createPage(routeName, args);
      pages.add(page);
    }
    final container = FusionContainer.restore(uniqueId, pages);

    /// Page's Visibility Change
    final previousRoute = FusionOverlayManager.instance.topRoute;
    _handlePageInvisible(previousRoute);
    _handlePageVisible(pages.last.route, isFirstTime: true);

    /// Insert overlay into the container
    FusionOverlayManager.instance.add(container);
    FusionChannel.instance.sync(container.uniqueId, container.pageEntities);
  }

  /// Hot Restart Restore
  void restoreAfterHotRestart() async {
    /// Restore containers and pages
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

    /// Page's Visibility Change
    final page = containers.last.topPage;
    page.containerVisible = true;
    _handlePageVisible(page.route, isFirstTime: true);
  }

  Future<void> destroy(String uniqueId) async {
    final container = FusionOverlayManager.instance.remove(uniqueId);
    if (container == null) {
      return;
    }
    FusionOverlayManager.instance.removeRoute(container.topPage.route);
  }

  void _handlePageVisible(
    Route? route, {
    bool isFirstTime = false,
  }) {
    if (route is! PageRoute) {
      return;
    }
    Future.microtask(() {
      FusionPage? page = FusionOverlayManager.instance.findPage(route);
      if (page == null) return;
      FusionPageLifecycleBinding.instance
          .dispatchPageVisibleEvent(route, isFirstTime: isFirstTime);
    });
  }

  void _handlePageInvisible(Route? route) {
    if (route is! PageRoute) {
      return;
    }
    FusionPage? page = FusionOverlayManager.instance.findPage(route);
    if (page == null) return;
    FusionPageLifecycleBinding.instance.dispatchPageInvisibleEvent(route);
  }
}
