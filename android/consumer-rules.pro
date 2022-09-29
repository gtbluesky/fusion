-keep class io.flutter.plugin.platform.PlatformPlugin {*;}
-keepclassmembers class io.flutter.embedding.android.FlutterFragment {
    io.flutter.embedding.android.FlutterActivityAndFragmentDelegate delegate;
}