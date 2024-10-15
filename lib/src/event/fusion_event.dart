import '../channel/fusion_channel.dart';

typedef FusionEventCallback = void Function(Map<String, dynamic>?);

class FusionEventManager {
  FusionEventManager._();

  static final FusionEventManager _instance = FusionEventManager._();

  static FusionEventManager get instance => _instance;

  final _callbackMap = <String, Set<FusionEventCallback>>{};

  /// Register the event callback.
  void register(String event, FusionEventCallback callback) {
    final callbacks = _callbackMap[event] ?? <FusionEventCallback>{};
    callbacks.add(callback);
    _callbackMap[event] = callbacks;
  }

  /// Unregister the event callback.
  void unregister(String event, [FusionEventCallback? callback]) {
    if (callback == null) {
      _callbackMap.remove(event);
    } else {
      _callbackMap[event]?.remove(callback);
    }
  }

  /// Send a event to flutter side and native side.
  void send(
    String event, {
    Map<String, dynamic>? args,
    FusionEventType type = FusionEventType.global,
  }) {
    switch (type) {
      case FusionEventType.flutter:
        _dispatchEvent(event, args);
        break;
      case FusionEventType.native:
        FusionChannel.instance.dispatchEvent(event, args);
        break;
      case FusionEventType.global:
        _dispatchEvent(event, args);
        FusionChannel.instance.dispatchEvent(event, args);
        break;
    }
  }

  void _dispatchEvent(String name, Map<String, dynamic>? args) {
    final callbacks =
        Set<FusionEventCallback>.unmodifiable(_callbackMap[name] ?? {});
    for (final callback in callbacks) {
      callback(args);
    }
  }
}

enum FusionEventType {
  flutter,
  native,
  global;
}
