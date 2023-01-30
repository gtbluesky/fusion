import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:fusion/src/channel/fusion_channel.dart';

class Fusion {
  Fusion._();

  static final Fusion _instance = Fusion._();

  static Fusion get instance => _instance;

  bool _installed = false;

  bool _mounted = false;

  /// If use `flutter_screenutil`, must call this method before runApp.
  void install() {
    if (_installed) {
      return;
    }
    _installed = true;
    WidgetsFlutterBinding.ensureInitialized();
    FusionChannel.instance.register();
  }
}

class FusionJobQueue {
  FusionJobQueue._();

  static final FusionJobQueue _instance = FusionJobQueue._();

  static FusionJobQueue get instance => _instance;

  final _jobQueue = DoubleLinkedQueue<Function>();

  void runJob(Function function) {
    if (Fusion.instance._mounted) {
      function.call();
    } else {
      _jobQueue.addLast(function);
    }
  }

  void mounted() {
    Fusion.instance._mounted = true;
    while (_jobQueue.isNotEmpty) {
      _jobQueue.removeFirst().call();
    }
  }
}
