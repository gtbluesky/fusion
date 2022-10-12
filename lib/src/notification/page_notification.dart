import 'package:flutter/material.dart';
import 'package:fusion/src/log/fusion_log.dart';

class PageNotificationListener {
  void onReceive(String msgName, Map<String, dynamic>? msgBody) {}
}

class PageNotificationBinding {
  PageNotificationBinding._();

  static final PageNotificationBinding _instance = PageNotificationBinding._();

  static PageNotificationBinding get instance => _instance;

  final _listeners = <Route<dynamic>, PageNotificationListener>{};

  void register(PageNotificationListener listener) {
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

  void unregister(PageNotificationListener listener) {
    if (listener is! State) {
      return;
    }
    _listeners.removeWhere((key, value) => value == listener);
  }

  void dispatchPageMessage(String msgName, Map<String, dynamic>? msgBody) {
    try {
      _listeners.forEach((key, value) {
        value.onReceive(msgName, msgBody);
      });
    } on Exception catch (e) {
      FusionLog.log(e.toString());
    }
  }
}
