import 'package:flutter/material.dart';
import 'package:fusion/fusion.dart';

import '../log/fusion_log.dart';

class FusionNavigatorObserver extends NavigatorObserver {

  bool isInitial = true;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    PageLifecycleBinding.instance.topRoute = route;
    if (isInitial) {
      isInitial = false;
      return;
    }
    PageLifecycleBinding.instance.dispatchPageVisibleEvent(route, isFirstTime: true);
    if (previousRoute != null) {
      PageLifecycleBinding.instance.dispatchPageInvisibleEvent(previousRoute);
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    PageLifecycleBinding.instance.dispatchPageInvisibleEvent(route);
    if (previousRoute != null) {
      PageLifecycleBinding.instance.topRoute = previousRoute;
      PageLifecycleBinding.instance.dispatchPageVisibleEvent(previousRoute);
    }
  }
}
