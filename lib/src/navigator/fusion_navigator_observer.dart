import 'package:flutter/material.dart';
import 'package:fusion/src/lifecycle/page_lifecycle.dart';
import 'package:fusion/src/navigator/fusion_navigator_delegate.dart';

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
    if (previousRoute is PageRoute) {
      PageLifecycleBinding.instance.dispatchPageInvisibleEvent(previousRoute);
    }
    if (route is PageRoute) {
      PageLifecycleBinding.instance.dispatchPageVisibleEvent(route, isFirstTime: true);
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute != null) {
      PageLifecycleBinding.instance.topRoute = previousRoute;
    }
    if (route is PageRoute) {
      PageLifecycleBinding.instance.dispatchPageInvisibleEvent(route);
    }
    if (previousRoute is PageRoute) {
      PageLifecycleBinding.instance.dispatchPageVisibleEvent(previousRoute);
    }
    if (isPopSliding) {
      FusionNavigatorDelegate.instance.popHistory();
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    if (previousRoute != null) {
      PageLifecycleBinding.instance.topRoute = previousRoute;
    }
    if (route is PageRoute) {
      PageLifecycleBinding.instance.dispatchPageInvisibleEvent(route);
    }
    if (previousRoute is PageRoute) {
      PageLifecycleBinding.instance.dispatchPageVisibleEvent(previousRoute);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) {
      PageLifecycleBinding.instance.topRoute = newRoute;
    }
    if (oldRoute is PageRoute) {
      PageLifecycleBinding.instance.dispatchPageInvisibleEvent(oldRoute);
    }
    if (newRoute is PageRoute) {
      PageLifecycleBinding.instance.dispatchPageVisibleEvent(newRoute);
    }
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    isPopSliding = true;
  }

  @override
  void didStopUserGesture() {
    isPopSliding = false;
  }
}
