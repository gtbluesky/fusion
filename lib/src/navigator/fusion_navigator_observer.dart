import 'package:flutter/material.dart';
import '../container/fusion_overlay.dart';

class FusionNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    final uniqueId = FusionOverlayManager.instance.topContainer()?.uniqueId;
    FusionOverlayManager.instance.containerRoutesMap[uniqueId]?.add(route);
    if (FusionNavigatorObserverManager.instance.consumeReplacePush(route)) {
      return;
    }
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
    if (FusionNavigatorObserverManager.instance.consumeReplaceRemove(route)) {
      return;
    }
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
    if (FusionNavigatorObserverManager.instance
        .consumeNativeDidReplace(newRoute: newRoute, oldRoute: oldRoute)) {
      return;
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

  Route? _replaceOldRoute;
  Route? _replaceNewRoute;
  bool _replaceNotified = false;
  bool _replaceSawRemove = false;
  bool _replaceSawPush = false;

  /// Pages-based [Navigator] treats a last-page swap as remove + push.
  /// Record the pair so [FusionNavigatorObserver] can emit [NavigatorObserver.didReplace]
  /// instead of forwarding only [NavigatorObserver.didRemove].
  void beginReplace({required Route oldRoute, required Route newRoute}) {
    _replaceOldRoute = oldRoute;
    _replaceNewRoute = newRoute;
    _replaceNotified = false;
    _replaceSawRemove = false;
    _replaceSawPush = false;
  }

  bool consumeReplaceRemove(Route route) {
    if (_replaceOldRoute != route) {
      return false;
    }
    _replaceSawRemove = true;
    _notifyDidReplace();
    _clearReplaceIfFinished();
    return true;
  }

  bool consumeReplacePush(Route route) {
    if (_replaceNewRoute != route) {
      return false;
    }
    _replaceSawPush = true;
    _notifyDidReplace();
    _clearReplaceIfFinished();
    return true;
  }

  /// Returns true when this native [NavigatorObserver.didReplace] belongs to a
  /// Fusion [beginReplace] pair (already forwarded or forwarded now).
  bool consumeNativeDidReplace({Route? newRoute, Route? oldRoute}) {
    if (_replaceOldRoute == null) {
      return false;
    }
    final matchesOld = oldRoute == null || oldRoute == _replaceOldRoute;
    final matchesNew = newRoute == null || newRoute == _replaceNewRoute;
    if (!matchesOld && !matchesNew) {
      return false;
    }
    _notifyDidReplace();
    _clearReplace();
    return true;
  }

  void _notifyDidReplace() {
    if (_replaceNotified || _replaceOldRoute == null) {
      return;
    }
    _replaceNotified = true;
    final newRoute = _replaceNewRoute;
    final oldRoute = _replaceOldRoute;
    navigatorObservers?.forEach((observer) {
      observer.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    });
  }

  void _clearReplaceIfFinished() {
    if (_replaceSawRemove && _replaceSawPush) {
      _clearReplace();
    }
  }

  void _clearReplace() {
    _replaceOldRoute = null;
    _replaceNewRoute = null;
    _replaceNotified = false;
    _replaceSawRemove = false;
    _replaceSawPush = false;
  }

  @visibleForTesting
  void debugReset() {
    navigatorObservers = null;
    _clearReplace();
  }
}
