import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('HarmonyOS FusionLifecycleCallback does not hardcode fullscreen', () {
    final source =
        File('ohos/src/main/ets/components/plugin/Fusion.ets').readAsStringSync();
    final lifecycleCallback = source.substring(
      source.indexOf('class FusionLifecycleCallback'),
    );
    expect(
      lifecycleCallback.contains('setWindowLayoutFullScreen(true)'),
      isFalse,
      reason: 'Fusion must not force fullscreen; the host app sets window layout.',
    );
    expect(lifecycleCallback.contains('onWindowStageCreate'), isTrue);
  });
}
