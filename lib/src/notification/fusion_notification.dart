import '../log/fusion_log.dart';

class FusionNotificationListener {
  /// Called when messages are received.
  void onReceive(String name, Map<String, dynamic>? body) {}
}

class FusionNotificationBinding {
  FusionNotificationBinding._();

  static final FusionNotificationBinding _instance =
      FusionNotificationBinding._();

  static FusionNotificationBinding get instance => _instance;

  final _listeners = <FusionNotificationListener>{};

  /// Register the notification listener.
  void register(FusionNotificationListener listener) {
    _listeners.add(listener);
  }

  /// Unregister the notification listener.
  void unregister(FusionNotificationListener listener) {
    _listeners.remove(listener);
  }

  void dispatchMessage(String name, Map<String, dynamic>? body) {
    try {
      for (final listener in _listeners) {
        listener.onReceive(name, body);
      }
    } on Exception catch (e) {
      FusionLog.log(e.toString());
    }
  }
}

enum FusionNotificationType {
  flutter,
  native,
  global;
}
