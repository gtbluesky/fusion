import 'package:flutter/material.dart';
import '../app/fusion_app.dart';
import '../channel/fusion_channel.dart';
import '../container/fusion_container.dart';
import '../container/fusion_overlay.dart';
import '../container/fusion_page.dart';
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
      /// Sync
      FusionChannel.instance.sync(container.uniqueId, container.pageEntities);
    });
    final page = FusionPage.createPage(routeName, args);

    /// Page's Visibility Change
    final previousRoute = FusionOverlayManager.instance.topRoute;
    _handlePageInvisible(previousRoute);
    _handlePageVisible(page.route, isFirstTime: true);
    return await container.push<dynamic>(page);
  }

  Future<T?> pushAndClear<T extends Object?>(
    String routeName, [
    Map<String, dynamic>? args,
  ]) async {
    final result = _push<T>(routeName, args);
    final containers =
        FusionOverlayManager.instance.containers.reversed.toList();
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
    for (final container in containers) {
      await FusionChannel.instance.destroy(container.uniqueId);
    }
    return result;
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
      topRoute?.navigator?.pop<T>(result);
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
      await FusionChannel.instance.destroy(container.uniqueId);
    }
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
    FusionContainer? targetContainer =
        FusionOverlayManager.instance.findContainerByPage(routeName);
    if (targetContainer == null) {
      return;
    }
    final targetPage = targetContainer.findPage(routeName);
    if (targetPage == null) {
      return;
    }
    final containers = FusionOverlayManager.instance.containers.reversed;
    final topContainer = containers.first;
    for (final container in containers) {
      if (container == targetContainer) {
        break;
      }
      await FusionChannel.instance.destroy(container.uniqueId);
    }
    if (targetPage == targetContainer.topPage) {
      return;
    }
    if (topContainer == targetContainer) {
      _handlePageInvisible(FusionOverlayManager.instance.topRoute);
      _handlePageVisible(targetPage.route);
    }
    final pages = targetContainer.pages.reversed.toList();
    final pendingPoppedPages = <FusionPage>[];
    for (final page in pages) {
      if (page == targetPage) {
        break;
      }
      pendingPoppedPages.add(page);
    }
    targetContainer.removeAll(pendingPoppedPages);
    FusionChannel.instance
        .sync(targetContainer.uniqueId, targetContainer.pageEntities);
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
      await FusionChannel.instance.destroy(container.uniqueId);
    }
  }

  bool hasRouteByName(String routeName) {
    FusionPage? page = FusionOverlayManager.instance.findPageByName(routeName);
    return page != null;
  }

  String get topRouteName {
    FusionPage? page = FusionOverlayManager.instance.topContainer()?.topPage;
    return page?.name ?? '';
  }

  void create(
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
    final route = container.topPage.route;
    FusionOverlayManager.instance.removeRoute(route);
    FusionNavigatorObserverManager.instance.navigatorObservers
        ?.forEach((observer) {
      observer.didPop(route, null);
    });
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
      FusionPageLifecycleManager.instance
          .dispatchPageVisibleEvent(route, isFirstTime: isFirstTime);
    });
  }

  void _handlePageInvisible(Route? route) {
    if (route is! PageRoute) {
      return;
    }
    FusionPage? page = FusionOverlayManager.instance.findPage(route);
    if (page == null) return;
    FusionPageLifecycleManager.instance.dispatchPageInvisibleEvent(route);
  }
}
