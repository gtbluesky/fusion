import 'package:flutter/material.dart';
import '../container/fusion_overlay.dart';

class FusionNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    final uniqueId = FusionOverlayManager.instance.topContainer()?.uniqueId;
    FusionOverlayManager.instance.containerRoutesMap[uniqueId]?.add(route);
    FusionNavigatorObserverManager.instance.navigatorObservers
        ?.forEach((observer) {
      observer.didPush(route, previousRoute);
    });
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    final uniqueId =
        FusionOverlayManager.instance.findContainerByRoute(route)?.uniqueId;
    FusionOverlayManager.instance.containerRoutesMap[uniqueId]?.remove(route);
    FusionNavigatorObserverManager.instance.navigatorObservers
        ?.forEach((observer) {
      observer.didPop(route, previousRoute);
    });
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    final uniqueId =
        FusionOverlayManager.instance.findContainerByRoute(route)?.uniqueId;
    FusionOverlayManager.instance.containerRoutesMap[uniqueId]?.remove(route);
    FusionNavigatorObserverManager.instance.navigatorObservers
        ?.forEach((observer) {
      observer.didRemove(route, previousRoute);
    });
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    final uniqueId = FusionOverlayManager.instance.topContainer()?.uniqueId;
    if (oldRoute != null) {
      FusionOverlayManager.instance.containerRoutesMap[uniqueId]
          ?.remove(oldRoute);
    }
    if (newRoute != null) {
      FusionOverlayManager.instance.containerRoutesMap[uniqueId]?.add(newRoute);
    }
    FusionNavigatorObserverManager.instance.navigatorObservers
        ?.forEach((observer) {
      observer.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    });
  }
}

/// showDialog & showModalBottomSheet等 useRootNavigator: true
class FusionRootNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    if (route is PageRoute) {
      return;
    }
    FusionOverlayManager.instance.rootRoutes.add(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    FusionOverlayManager.instance.rootRoutes.remove(route);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    FusionOverlayManager.instance.rootRoutes.remove(route);
  }
}

class FusionNavigatorObserverManager {
  FusionNavigatorObserverManager._();
  static final _instance = FusionNavigatorObserverManager._();
  static FusionNavigatorObserverManager get instance => _instance;
  List<NavigatorObserver>? navigatorObservers;
}
