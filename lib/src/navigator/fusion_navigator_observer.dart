import 'package:flutter/material.dart';
import 'package:fusion/src/container/fusion_overlay.dart';

class FusionNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    FusionOverlayManager.instance.addRoute(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    FusionOverlayManager.instance.removeRoute(route);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    FusionOverlayManager.instance.removeRoute(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (oldRoute != null) {
      FusionOverlayManager.instance.removeRoute(oldRoute);
    }
    if (newRoute != null) {
      FusionOverlayManager.instance.addRoute(newRoute);
    }
  }
}
