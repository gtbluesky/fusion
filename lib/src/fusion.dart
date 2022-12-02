import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:fusion/src/channel/fusion_channel.dart';

class Fusion {
  Fusion._();

  static final Fusion _instance = Fusion._();

  static Fusion get instance => _instance;

  bool _installed = false;

  bool _mounted = false;

  final _jobQueue = DoubleLinkedQueue<Function>();

  void install() {
    if (_installed) {
      return;
    }
    _installed = true;
    WidgetsFlutterBinding.ensureInitialized();
    FusionChannel.instance.register();
  }

  void runJob(Function function) {
    if (_mounted) {
      function.call();
    } else {
      _jobQueue.addLast(function);
    }
  }

  void mounted() {
    _mounted = true;
    while(_jobQueue.isNotEmpty) {
      _jobQueue.removeFirst().call();
    }
  }
}
