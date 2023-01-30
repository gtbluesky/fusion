-keepclassmembers class io.flutter.plugin.platform.PlatformPlugin {
    io.flutter.embedding.engine.systemchannels.PlatformChannel$SystemChromeStyle currentTheme;
}
-keepclassmembers class io.flutter.plugin.platform.PlatformViewsController {
    io.flutter.embedding.engine.systemchannels.PlatformViewsChannel platformViewsChannel;
    io.flutter.embedding.engine.systemchannels.PlatformViewsChannel$PlatformViewsHandler channelHandler;
}
-keepclassmembers class io.flutter.embedding.android.FlutterFragment {
    io.flutter.embedding.android.FlutterActivityAndFragmentDelegate delegate;
}