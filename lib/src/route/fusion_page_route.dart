import 'package:flutter/material.dart';
import 'package:fusion/src/data/fusion_data.dart';
import 'package:fusion/src/widget/fusion_will_pop_scope.dart';

class FusionPageRoute<T> extends MaterialPageRoute<T> {
  /// 容器内的Flutter首页
  final bool home;

  final List<WillPopCallback> _scopedWillPopCallbacks = <WillPopCallback>[];
  FusionWillPopCallback? _fusionWillPopCallback;

  FusionPageRoute({
    required WidgetBuilder builder,
    required RouteSettings settings,
    this.home = false,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
          builder: builder,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
        );

  @override
  Duration get transitionDuration {
    if (home == true) {
      return const Duration(milliseconds: 0);
    } else {
      return FusionData.transitionDuration;
    }
  }

  @override
  Duration get reverseTransitionDuration {
    if (home == true) {
      return const Duration(milliseconds: 0);
    } else {
      return FusionData.reverseTransitionDuration;
    }
  }

  @override
  Future<RoutePopDisposition> willPop() async {
    return willPopResult();
  }

  Future<RoutePopDisposition> willPopResult([dynamic result]) async {
    for (final WillPopCallback callback in List.of(_scopedWillPopCallbacks)) {
      if (await callback() != true) {
        return RoutePopDisposition.doNotPop;
      }
    }
    if (await _fusionWillPopCallback?.call(result) != true) {
      return RoutePopDisposition.doNotPop;
    }
    return super.willPop();
  }

  //WillPopScope
  @override
  void addScopedWillPopCallback(WillPopCallback callback) {
    super.addScopedWillPopCallback(callback);
    _scopedWillPopCallbacks.add(callback);
  }

  @override
  void removeScopedWillPopCallback(WillPopCallback callback) {
    super.removeScopedWillPopCallback(callback);
    _scopedWillPopCallbacks.remove(callback);
  }

  //FusionWillPopScope
  void setFusionWillPopCallback(FusionWillPopCallback? callback) {
    _fusionWillPopCallback = callback;
  }

  /// 处理iOS滑动退出
  @override
  @protected
  bool get hasScopedWillPopCallback {
    if (home == true) {
      return true;
    } else {
      return _scopedWillPopCallbacks.isNotEmpty;
    }
  }
}
