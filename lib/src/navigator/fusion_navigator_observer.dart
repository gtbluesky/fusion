import 'package:flutter/material.dart';
import 'package:fusion/src/lifecycle/page_lifecycle.dart';
import 'package:fusion/src/navigator/fusion_navigator_delegate.dart';
import 'package:fusion/src/route/fusion_page_route.dart';

class FusionNavigatorObserver extends NavigatorObserver {
  FusionNavigatorObserver._();

  static final FusionNavigatorObserver _instance = FusionNavigatorObserver._();

  static FusionNavigatorObserver get instance => _instance;

  bool isInitial = true;

  bool isPopSliding = false;

  @override
  void didPush(Route route, Route? previousRoute) {
    PageLifecycleBinding.instance.topRoute = route;
    if (isInitial) {
      isInitial = false;
      return;
    }
    _handlePageInvisible(previousRoute);
    _handlePageVisible(route, isFirstTime: true);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute != null) {
      PageLifecycleBinding.instance.topRoute = previousRoute;
    }
    _handlePageInvisible(route);
    _handlePageVisible(previousRoute);
    if (isPopSliding) {
      FusionNavigatorDelegate.instance.popHistory();
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    if (previousRoute != null) {
      PageLifecycleBinding.instance.topRoute = previousRoute;
    }
    _handlePageInvisible(route);
    _handlePageVisible(previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) {
      PageLifecycleBinding.instance.topRoute = newRoute;
    }
    _handlePageInvisible(oldRoute);
    _handlePageVisible(newRoute);
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    isPopSliding = true;
  }

  @override
  void didStopUserGesture() {
    isPopSliding = false;
  }

  void _handlePageVisible(
    Route? route, {
    bool isFirstTime = false,
  }) {
    if (route is FusionPageRoute && !route.isVisible) {
      route.pageInTop = true;
      if (route.isVisible) {
        PageLifecycleBinding.instance
            .dispatchPageVisibleEvent(route, isFirstTime: isFirstTime);
      }
    }
  }

  void _handlePageInvisible(Route? route) {
    if (route is FusionPageRoute) {
      if (route.isVisible) {
        PageLifecycleBinding.instance.dispatchPageInvisibleEvent(route);
      }
      route.pageInTop = false;
    }
  }
}
