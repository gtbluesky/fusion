import 'package:flutter/material.dart';

import '../data/fusion_data.dart';

class FusionPage<T> extends MaterialPage<T> {

  final bool home;

  const FusionPage({required Widget child, name, arguments, this.home = false})
      : super(child: child, name: name, arguments: arguments);

  @override
  Route<T> createRoute(BuildContext context) {
    return FusionPageBasedMaterialPageRoute(page: this);
  }
}

class FusionPageBasedMaterialPageRoute<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin {
  FusionPageBasedMaterialPageRoute({
    required FusionPage<T> page,
  }) : super(settings: page) {
    assert(opaque);
  }

  MaterialPage<T> get _page => settings as MaterialPage<T>;

  @override
  Duration get transitionDuration {
    if ((settings as FusionPage?)?.home == true) {
      return const Duration(milliseconds: 0);
    } else {
      return FusionData.transitionDuration;
    }
  }

  @override
  Duration get reverseTransitionDuration {
    if ((settings as FusionPage?)?.home == true) {
      return const Duration(milliseconds: 0);
    } else {
      return FusionData.reverseTransitionDuration;
    }
  }

  @override
  @protected
  bool get hasScopedWillPopCallback {
    if ((settings as FusionPage?)?.home == true) {
      return true;
    } else {
      return super.hasScopedWillPopCallback;
    }
  }

  @override
  Widget buildContent(BuildContext context) {
    return _page.child;
  }

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
}
