import 'package:flutter/material.dart';

import '../log/fusion_log.dart';

class PageLifecycleListener {
  void onPageVisible() {}

  void onPageInvisible() {}

  void onForeground() {}

  void onBackground() {}
}

class PageLifecycleBinding {
  PageLifecycleBinding._();

  static final PageLifecycleBinding _instance = PageLifecycleBinding._();

  static PageLifecycleBinding get instance => _instance;

  final _listeners = <Route<dynamic>, PageLifecycleListener>{};

  late Route topRoute;

  void register(PageLifecycleListener listener) {
    if (listener is! State) {
      return;
    }
    final context = (listener as State).context;
    Route<dynamic>? route = ModalRoute.of(context);
    if (route == null) {
      return;
    }
    _listeners[route] = listener;
    // FusionLog.log('addObserver.route:${route.runtimeType}@${route.hashCode}');
    // FusionLog.log('addObserver.state:${observer.runtimeType}@${observer.hashCode}');
  }

  void unregister(PageLifecycleListener listener) {
    if (listener is! State) {
      return;
    }
    _listeners.removeWhere((key, value) => value == listener);
  }

  void dispatchPageVisibleEvent(Route<dynamic> route,
      {bool isFirstTime = false}) {
    // _listeners.forEach((key, value) {
    //   FusionLog.log('_listeners.route:${key.runtimeType}@${key.hashCode}');
    //   FusionLog.log('_listeners.state:${value.runtimeType}@${value.hashCode}');
    // });
    if (isFirstTime) {
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