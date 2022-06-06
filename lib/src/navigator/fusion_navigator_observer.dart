import 'package:flutter/material.dart';
import 'package:fusion/src/navigator/fusion_navigator_delegate.dart';

import '../lifecycle/page_lifecycle.dart';

class FusionNavigatorObserver extends NavigatorObserver {

  FusionNavigatorObserver._();

  static final FusionNavigatorObserver _instance = FusionNavigatorObserver._();

  static FusionNavigatorObserver get instance => _instance;

  bool isInitial = true;

  bool isPopSliding = false;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
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
    if (!isPopSliding) {
      return;
    }
    FusionNavigatorDelegate.instance.popHistory();
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    super.didStartUserGesture(route, previousRoute);
    isPopSliding = true;
  }

  @override
  void didStopUserGesture() {
    super.didStopUserGesture();
    isPopSliding = false;
  }
}
