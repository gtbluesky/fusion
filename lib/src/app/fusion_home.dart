import 'package:flutter/material.dart';

final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();

class FusionHome extends StatefulWidget {
  const FusionHome({Key? key}) : super(key: key);

  @override
  State<FusionHome> createState() => _FusionHomeState();
}

class _FusionHomeState extends State<FusionHome> {

  @override
  Widget build(BuildContext context) {
    return Overlay(
      key: overlayKey,
    );
  }
}
