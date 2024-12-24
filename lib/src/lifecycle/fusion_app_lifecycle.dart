import '../log/fusion_log.dart';

mixin FusionAppLifecycleListener {
  /// Called when the app switches from the background to the foreground.
  void onForeground() {}

  /// Called when the app switches from the foreground to the background.
  void onBackground() {}
}

class FusionAppLifecycleManager {
  FusionAppLifecycleManager._();

  static final FusionAppLifecycleManager _instance =
      FusionAppLifecycleManager._();

  static FusionAppLifecycleManager get instance => _instance;

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
    final listeners = Set<FusionAppLifecycleListener>.unmodifiable(_listeners);
    for (final listener in listeners) {
      try {
        listener.onForeground();
      } on Exception catch (e) {
        FusionLog.log(e.toString());
      }
    }
  }

  void dispatchAppBackgroundEvent() {
    final listeners = Set<FusionAppLifecycleListener>.unmodifiable(_listeners);
    for (final listener in listeners) {
      try {
        listener.onBackground();
      } on Exception catch (e) {
        FusionLog.log(e.toString());
      }
    }
  }
}
