import '../navigator/fusion_navigator.dart';

class FusionInterceptorOption {
  FusionInterceptorOption({this.routeName, this.args, this.type});

  String? routeName;
  Map<String, dynamic>? args;
  FusionRouteType? type;
}

/// The result type after handled by the interceptor.
enum InterceptorResultType {
  next,
  resolve,
  reject,
}

/// Used to pass state between interceptors.
class InterceptorState<T> {
  const InterceptorState(this.data, [this.type = InterceptorResultType.next]);

  final T data;
  final InterceptorResultType type;

  @override
  String toString() => 'InterceptorState<$T>(type: $type, data: $data)';
}

abstract class _BaseHandler<T> {
  InterceptorState<T> get state => _state;
  late InterceptorState<T> _state;
}

/// The handler for interceptors to handle before push or pop action.
class InterceptorHandler extends _BaseHandler<FusionInterceptorOption> {
  /// Deliver the [option] to the next interceptor.
  void next(FusionInterceptorOption option) {
    _state = InterceptorState<FusionInterceptorOption>(option);
  }

  /// Completes the push or pop action by resolves the [option] as the result.
  void resolve(FusionInterceptorOption option) {
    _state = InterceptorState<FusionInterceptorOption>(
        option, InterceptorResultType.resolve);
  }

  void reject(FusionInterceptorOption option) {
    _state = InterceptorState<FusionInterceptorOption>(
        option, InterceptorResultType.reject);
  }
}

class FusionInterceptor {
  const FusionInterceptor();

  void onPush(FusionInterceptorOption option, InterceptorHandler handler) {
    handler.next(option);
  }

  void onPop(FusionInterceptorOption option, InterceptorHandler handler) {
    handler.next(option);
  }
}
