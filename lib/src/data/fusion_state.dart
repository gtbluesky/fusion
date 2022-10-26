import 'dart:ui' as ui;

import 'package:fusion/src/constant/fusion_constant.dart';

class FusionState {
  static bool isReused = ui.window.defaultRouteName == kReuseMode;
  static bool isRestoring = false;
}
