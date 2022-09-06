import 'package:flutter/material.dart';

import '../lifecycle/page_lifecycle.dart';

class FusionNavigatorObserver extends NavigatorObserver {
  bool isInitial = true;

  @override
  void didPush(Route route, Route? previousRoute) {
    PageLifecycleBinding.instance.topRoute = route;
    if (isInitial) {
      isInitial = false;
      return;
    }
    if (route is PageRoute) {
      PageLifecycleBinding.instance.dispatchPageVisibleEvent(route, isFirstTime: true);
    }
    if (previousRoute != null) {
      PageLifecycleBinding.instance.dispatchPageInvisibleEvent(previousRoute);
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
    if (previousRoute != null) {
      PageLifecycleBinding.instance.dispatchPageVisibleEvent(previousRoute);
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
    if (previousRoute != null) {
      PageLifecycleBinding.instance.dispatchPageVisibleEvent(previousRoute);
    }
  }
}
