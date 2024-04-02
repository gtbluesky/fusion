import '../log/fusion_log.dart';

class FusionAppLifecycleListener {
  /// Called when the app switches from the background to the foreground.
  void onForeground() {}

  /// Called when the app switches from the foreground to the background.
  void onBackground() {}
}

class FusionAppLifecycleBinding {
  FusionAppLifecycleBinding._();

  static final FusionAppLifecycleBinding _instance =
      FusionAppLifecycleBinding._();

  static FusionAppLifecycleBinding get instance => _instance;

  final _listeners = <FusionAppLifecycleListener>{};

  /// Register the app's lifecycle listener.
  void register(FusionAppLifecycleListener listener) {
    _listeners.add(listener);
  }

  /// Unregister the app's lifecycle listener.
  void unregister(FusionAppLifecycleListener listener) {
    _listeners.remove(listener);
  }

  void dispatchAppForegroundEvent() {
    for (final listener in _listeners) {
      try {
        listener.onForeground();
      } on Exception catch (e) {
        FusionLog.log(e.toString());
      }
    }
  }

  void dispatchAppBackgroundEvent() {
    for (final listener in _listeners) {
      try {
        listener.onBackground();
      } on Exception catch (e) {
        FusionLog.log(e.toString());
      }
    }
  }
}
