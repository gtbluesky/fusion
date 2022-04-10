import 'package:flutter/foundation.dart';

class FusionLog {
  static log(String msg) {
    if (!kDebugMode) {
      return;
    }
    debugPrint(msg);
  }
}
