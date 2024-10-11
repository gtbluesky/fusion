import 'package:flutter/material.dart';
import '../container/fusion_overlay.dart';

class FusionNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    FusionOverlayManager.instance.addRoute(route);
    FusionNavigatorObserverManager.instance.navigatorObservers
        ?.forEach((observer) {
      observer.didPush(route, previousRoute);
    });
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    FusionOverlayManager.instance.removeRoute(route);
    FusionNavigatorObserverManager.instance.navigatorObservers
        ?.forEach((observer) {
      observer.didPop(route, previousRoute);
    });
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    FusionOverlayManager.instance.removeRoute(route);
    FusionNavigatorObserverManager.instance.navigatorObservers
        ?.forEach((observer) {
      observer.didRemove(route, previousRoute);
    });
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (oldRoute != null) {
      FusionOverlayManager.instance.removeRoute(oldRoute);
    }
    if (newRoute != null) {
      FusionOverlayManager.instance.addRoute(newRoute);
    }
    FusionNavigatorObserverManager.instance.navigatorObservers
        ?.forEach((observer) {
      observer.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    });
  }
}

class FusionRootNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    if (route is PageRoute) {
      return;
    }
    FusionOverlayManager.instance.addRoute(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    FusionOverlayManager.instance.removeRoute(route);
  }
}

class FusionNavigatorObserverManager {
  FusionNavigatorObserverManager._();
  static final _instance = FusionNavigatorObserverManager._();
  static FusionNavigatorObserverManager get instance => _instance;
  List<NavigatorObserver>? navigatorObservers;
}
