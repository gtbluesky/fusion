import 'package:flutter/material.dart';
import 'package:fusion/src/navigator/fusion_navigator_delegate.dart';

final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();

class FusionHome extends StatefulWidget {
  const FusionHome({Key? key}) : super(key: key);

  @override
  State<FusionHome> createState() => _FusionHomeState();
}

class _FusionHomeState extends State<FusionHome> {

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        FusionNavigatorDelegate.instance.maybePop();
        return false;
      },
      child: Overlay(
        key: overlayKey,
      ),
    );
  }
}
