import 'package:flutter/material.dart';

import '../log/fusion_log.dart';

class PageLifecycleObserver {
  void onPageVisible() {}

  void onPageInvisible() {}

  void onForeground() {}

  void onBackground() {}
}

class PageLifecycleBinding {
  PageLifecycleBinding._();

  static final PageLifecycleBinding _instance = PageLifecycleBinding._();

  static PageLifecycleBinding get instance => _instance;

  final _listeners = <Route<dynamic>, PageLifecycleObserver>{};

  late Route topRoute;

  void register(PageLifecycleObserver observer) {
    if (observer is! State) {
      return;
    }
    final context = (observer as State).context;
    Route<dynamic>? route = ModalRoute.of(context);
    if (route == null) {
      return;
    }
    _listeners[route] = observer;
    // FusionLog.log('addObserver.route:${route.runtimeType}@${route.hashCode}');
    // FusionLog.log('addObserver.state:${observer.runtimeType}@${observer.hashCode}');
  }

  void unregister(PageLifecycleObserver observer) {
    if (observer is! State) {
      return;
    }
    _listeners.removeWhere((key, value) => value == observer);
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
