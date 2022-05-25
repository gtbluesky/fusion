import 'package:flutter/material.dart';
import 'package:fusion/src/log/fusion_log.dart';

import '../lifecycle/page_lifecycle.dart';

class FusionNavigatorObserver extends NavigatorObserver {
  bool isInitial = true;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    FusionLog.log(
        "didPush route:${route.runtimeType}@${route.hashCode}\npreviousRoute:${previousRoute.runtimeType}@${previousRoute.hashCode}");
    PageLifecycleBinding.instance.topRoute = route;
    if (isInitial) {
      isInitial = false;
      return;
    }
    if (route is! PageRoute) {
      return;
    }
    PageLifecycleBinding.instance
        .dispatchPageVisibleEvent(route, isFirstTime: true);
    if (previousRoute != null) {
      PageLifecycleBinding.instance.dispatchPageInvisibleEvent(previousRoute);
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    FusionLog.log(
        "didPop route:${route.runtimeType}@${route.hashCode}\npreviousRoute:${previousRoute.runtimeType}@${previousRoute.hashCode}");
    if (previousRoute != null) {
      PageLifecycleBinding.instance.topRoute = previousRoute;
    }
    if (route is! PageRoute) {
      return;
    }
    PageLifecycleBinding.instance.dispatchPageInvisibleEvent(route);
    if (previousRoute != null) {
      PageLifecycleBinding.instance.dispatchPageVisibleEvent(previousRoute);
    }
  }
}
