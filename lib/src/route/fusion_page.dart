import 'package:flutter/material.dart';

import '../data/fusion_data.dart';

class FusionPage<T> extends MaterialPage<T> {

  final bool isFirstPage;

  const FusionPage({required Widget child, name, arguments, this.isFirstPage = false})
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
  Duration get transitionDuration => (settings as FusionPage?)?.isFirstPage == true ? const Duration(milliseconds: 0) : FusionData.transitionDuration;

  @override
  Duration get reverseTransitionDuration => (settings as FusionPage?)?.isFirstPage == true ? const Duration(milliseconds: 0) : FusionData.reverseTransitionDuration;

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
