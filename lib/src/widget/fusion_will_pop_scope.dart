import 'package:flutter/material.dart';
import 'package:fusion/src/route/fusion_page_route.dart';

typedef FusionWillPopCallback = Future<bool> Function([dynamic result]);

class FusionWillPopScope extends StatefulWidget {
  const FusionWillPopScope({
    Key? key,
    required this.child,
    required this.onWillPopResult,
  }) : super(key: key);

  final Widget child;

  final FusionWillPopCallback? onWillPopResult;

  @override
  State<FusionWillPopScope> createState() => _FusionWillPopScopeState();
}

class _FusionWillPopScopeState extends State<FusionWillPopScope> {
  FusionPageRoute<dynamic>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.onWillPopResult != null) {
      _route?.setFusionWillPopCallback(null);
    }
    _route = ModalRoute.of(context) as FusionPageRoute?;
    if (widget.onWillPopResult != null) {
      _route?.setFusionWillPopCallback(widget.onWillPopResult);
    }
  }

  @override
  void didUpdateWidget(covariant FusionWillPopScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onWillPopResult != oldWidget.onWillPopResult && _route != null) {
      if (oldWidget.onWillPopResult != null) {
        _route?.setFusionWillPopCallback(null);
      }
      if (widget.onWillPopResult != null) {
        _route?.setFusionWillPopCallback(widget.onWillPopResult);
      }
    }
  }

  @override
  void dispose() {
    if (widget.onWillPopResult != null) {
      _route?.setFusionWillPopCallback(null);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
