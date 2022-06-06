import 'package:flutter/material.dart';

import '../data/fusion_data.dart';

class FusionPageRoute<T> extends MaterialPageRoute<T> {
  final bool home;

  final List<WillPopCallback> scopedWillPopCallbacks = <WillPopCallback>[];

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
  void addScopedWillPopCallback(WillPopCallback callback) {
    super.addScopedWillPopCallback(callback);
    scopedWillPopCallbacks.add(callback);
  }

  @override
  void removeScopedWillPopCallback(WillPopCallback callback) {
    super.removeScopedWillPopCallback(callback);
    scopedWillPopCallbacks.remove(callback);
  }

  @override
  @protected
  bool get hasScopedWillPopCallback {
    if (home == true) {
      return true;
    } else {
      return scopedWillPopCallbacks.length > 1;
    }
  }
}
