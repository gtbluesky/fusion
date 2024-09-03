import 'package:flutter/material.dart';
import '../log/fusion_log.dart';

abstract class FusionPageLifecycleListener {
  /// Called when the flutter page is visible.
  void onPageVisible();

  /// Called when the flutter page is invisible.
  void onPageInvisible();

  /// Called when the app switches from the background to the foreground.
  void onForeground();

  /// Called when the app switches from the foreground to the background.
  void onBackground();
}

mixin FusionPageLifecycleMixin<T extends StatefulWidget> on State<T>
    implements FusionPageLifecycleListener {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FusionPageLifecycleManager.instance.register(this);
  }

  @override
  void dispose() {
    FusionPageLifecycleManager.instance.unregister(this);
    super.dispose();
  }

  @override
  void onPageVisible() {}

  @override
  void onPageInvisible() {}

  @override
  void onForeground() {}

  @override
  void onBackground() {}
}

class FusionPageLifecycleManager {
  FusionPageLifecycleManager._();

  static final FusionPageLifecycleManager _instance =
      FusionPageLifecycleManager._();

  static FusionPageLifecycleManager get instance => _instance;

  final _listenerMap = <Route<dynamic>, Set<FusionPageLifecycleListener>>{};
  final _routeMap = <FusionPageLifecycleListener, Route<dynamic>>{};

  /// Register the page's lifecycle listener.
  void register(FusionPageLifecycleListener listener) {
    if (listener is! State) {
      return;
    }
    final context = (listener as State).context;
    Route<dynamic>? route = ModalRoute.of(context);
    if (route == null) {
      return;
    }
    final listeners = _listenerMap[route] ?? <FusionPageLifecycleListener>{};
    listeners.add(listener);
    _listenerMap[route] = listeners;
    _routeMap[listener] = route;
  }

  /// Unregister the page's lifecycle listener.
  void unregister(FusionPageLifecycleListener listener) {
    if (listener is! State) {
      return;
    }
    Route<dynamic>? route = _routeMap.remove(listener);
    if (route == null) {
      return;
    }
    final listeners = _listenerMap.remove(route);
    listeners?.remove(listener);
    if (listeners != null && listeners.isNotEmpty) {
      _listenerMap[route] = listeners;
    }
  }

  void dispatchPageVisibleEvent(
    Route<dynamic> route, {
    bool isFirstTime = false,
  }) {
    /// 确保didChangeDependencies后调用生命周期方法
    if (isFirstTime) {
      // ignore: invalid_null_aware_operator
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        try {
          _listenerMap[route]?.forEach((listener) {
            listener.onPageVisible();
          });
        } on Exception catch (e) {
          FusionLog.log(e.toString());
        }
      });
    } else {
      try {
        _listenerMap[route]?.forEach((listener) {
          listener.onPageVisible();
        });
      } on Exception catch (e) {
        FusionLog.log(e.toString());
      }
    }
  }

  void dispatchPageInvisibleEvent(Route<dynamic> route) {
    try {
      _listenerMap[route]?.forEach((listener) {
        listener.onPageInvisible();
      });
    } on Exception catch (e) {
      FusionLog.log(e.toString());
    }
  }

  void dispatchPageForegroundEvent() {
    _listenerMap.forEach((key, value) {
      try {
        for (final listener in value) {
          listener.onForeground();
        }
      } on Exception catch (e) {
        FusionLog.log(e.toString());
      }
    });
  }

  void dispatchPageBackgroundEvent() {
    _listenerMap.forEach((key, value) {
      try {
        for (final listener in value) {
          listener.onBackground();
        }
      } on Exception catch (e) {
        FusionLog.log(e.toString());
      }
    });
  }
}
