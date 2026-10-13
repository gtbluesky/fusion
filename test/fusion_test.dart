import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('fusion');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  // test('getPlatformVersion', () async {
  //   expect(await Fusion.platformVersion, '42');
  // });

  test('FusionViewController is an Objective-C class that can be subclassed', () {
    final header = File('ios/Classes/Container/FusionViewController.h').readAsStringSync();
    expect(header.contains('objc_subclassing_restricted'), isFalse);
    expect(header.contains('NS_SWIFT_UI_ACTOR'), isFalse);
    expect(header.contains('SWIFT_CLASS'), isFalse);
    expect(
      header.contains('@interface FusionViewController : FlutterViewController'),
      isTrue,
    );

    final swift = File('ios/Classes/Container/FusionViewController.swift').readAsStringSync();
    expect(RegExp(r'\b(?:final\s+)?class\s+FusionViewController\b').hasMatch(swift), isFalse);
    expect(swift.contains('extension FusionViewController'), isTrue);

    final subclassCheck = File('test/ios/CustomFusionViewController.h').readAsStringSync();
    expect(
      subclassCheck.contains('@interface CustomFusionViewController : FusionViewController'),
      isTrue,
    );
  });
}
