import 'package:flutter/material.dart';
import '../log/fusion_log.dart';

mixin FusionPageLifecycleListener {
  /// Called when the flutter page is visible.
  void onPageVisible() {}

  /// Called when the flutter page is invisible.
  void onPageInvisible() {}

  /// Called when the app switches from the background to the foreground.
  void onForeground() {}

  /// Called when the app switches from the foreground to the background.
  void onBackground() {}
}

class FusionPageLifecycleManager {
  FusionPageLifecycleManager._();

  static final FusionPageLifecycleManager _instance =
      FusionPageLifecycleManager._();

  static FusionPageLifecycleManager get instance => _instance;

  final _listeners = <Route<dynamic>, FusionPageLifecycleListener>{};

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
    _listeners[route] = listener;
  }

  /// Unregister the page's lifecycle listener.
  void unregister(FusionPageLifecycleListener listener) {
    if (listener is! State) {
      return;
    }
    _listeners.removeWhere((key, value) => value == listener);
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
          _listeners[route]?.onPageVisible();
        } on Exception catch (e) {
          FusionLog.log(e.toString());
        }
      });
    } else {
      try {
        _listeners[route]?.onPageVisible();
      } on Exception catch (e) {
        FusionLog.log(e.toString());
      }
    }
  }

  void dispatchPageInvisibleEvent(Route<dynamic> route) {
    try {
      _listeners[route]?.onPageInvisible();
    } on Exception catch (e) {
      FusionLog.log(e.toString());
    }
  }

  void dispatchPageForegroundEvent() {
    _listeners.forEach((key, value) {
      try {
        value.onForeground();
      } on Exception catch (e) {
        FusionLog.log(e.toString());
      }
    });
  }

  void dispatchPageBackgroundEvent() {
    _listeners.forEach((key, value) {
      try {
        value.onBackground();
      } on Exception catch (e) {
        FusionLog.log(e.toString());
      }
    });
  }
}