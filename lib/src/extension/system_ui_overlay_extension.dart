import 'package:flutter/services.dart';

extension SystemUiOverlayStyleExtension on SystemUiOverlayStyle {
  Map<String, dynamic>? toMap() {
    return <String, dynamic>{
      'systemNavigationBarColor': systemNavigationBarColor?.value,
      'systemNavigationBarDividerColor': systemNavigationBarDividerColor?.value,
      'systemStatusBarContrastEnforced': systemStatusBarContrastEnforced,
      'statusBarColor': statusBarColor?.value,
      'statusBarBrightness': statusBarBrightness?.toString(),
      'statusBarIconBrightness': statusBarIconBrightness?.toString(),
      'systemNavigationBarIconBrightness': systemNavigationBarIconBrightness?.toString(),
      'systemNavigationBarContrastEnforced': systemNavigationBarContrastEnforced,
    };
  }
}