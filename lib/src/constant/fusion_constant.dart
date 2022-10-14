import 'dart:ui' as ui;

const kUnknownRoute = '/404';
const kReuseMode = 'reuse_mode';
bool isReused = ui.window.defaultRouteName == kReuseMode;