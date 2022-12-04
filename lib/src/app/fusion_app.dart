import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fusion/src/app/fusion_home.dart';
import 'package:fusion/src/data/fusion_data.dart';
import 'package:fusion/src/data/fusion_state.dart';
import 'package:fusion/src/fusion.dart';
import 'package:fusion/src/navigator/fusion_navigator_delegate.dart';

typedef FusionPageFactory = Widget Function(Map<String, dynamic>? arguments);
typedef FusionPageCustomFactory = PageRoute Function(RouteSettings settings);

class FusionApp extends StatefulWidget {
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final String title;
  final GenerateAppTitle? onGenerateTitle;
  final Color? color;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeData? highContrastTheme;
  final ThemeData? highContrastDarkTheme;
  final ThemeMode? themeMode;
  final Locale? locale;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final LocaleListResolutionCallback? localeListResolutionCallback;
  final LocaleResolutionCallback? localeResolutionCallback;
  final Iterable<Locale> supportedLocales;
  final bool debugShowMaterialGrid;
  final bool showPerformanceOverlay;
  final bool checkerboardRasterCacheImages;
  final bool checkerboardOffscreenLayers;
  final bool showSemanticsDebugger;
  final bool debugShowCheckedModeBanner;
  final Map<Type, Action<Intent>>? actions;
  final String? restorationScopeId;

  FusionApp({
    Map<String, FusionPageFactory>? routeMap,
    Map<String, FusionPageCustomFactory>? customRouteMap,
    Key? key,
    this.scaffoldMessengerKey,
    this.title = '',
    this.onGenerateTitle,
    this.color,
    this.theme,
    this.darkTheme,
    this.highContrastTheme,
    this.highContrastDarkTheme,
    this.themeMode = ThemeMode.system,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.actions,
    this.restorationScopeId,
    Duration transitionDuration = const Duration(milliseconds: 300),
    Duration reverseTransitionDuration = const Duration(milliseconds: 300),
  }) : super(key: key) {
    assert(routeMap != null || customRouteMap != null);
    FusionNavigatorDelegate.instance.routeMap = routeMap;
    FusionNavigatorDelegate.instance.customRouteMap = customRouteMap;
    FusionData.transitionDuration = transitionDuration;
    FusionData.reverseTransitionDuration = reverseTransitionDuration;
  }

  @override
  State<FusionApp> createState() => _FusionAppState();
}

class _FusionAppState extends State<FusionApp> {
  @override
  void initState() {
    super.initState();
    Fusion.instance.install();

    /// Make sure that the widget in the tree is already mounted.
    // ignore: invalid_null_aware_operator
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      Fusion.instance.mounted();
      if (!kDebugMode || FusionState.isRestoring) {
        return;
      }
      FusionNavigatorDelegate.instance.restoreAfterHotRestart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: widget.scaffoldMessengerKey,
      builder: (_, __) => const FusionHome(),
      title: widget.title,
      onGenerateTitle: widget.onGenerateTitle,
      color: widget.color,
      theme: widget.theme,
      darkTheme: widget.darkTheme,
      highContrastTheme: widget.highContrastTheme,
      highContrastDarkTheme: widget.highContrastDarkTheme,
      themeMode: widget.themeMode,
      locale: widget.locale,
      localizationsDelegates: widget.localizationsDelegates,
      localeListResolutionCallback: widget.localeListResolutionCallback,
      localeResolutionCallback: widget.localeResolutionCallback,
      supportedLocales: widget.supportedLocales,
      debugShowMaterialGrid: widget.debugShowMaterialGrid,
      showPerformanceOverlay: widget.showPerformanceOverlay,
      checkerboardRasterCacheImages: widget.checkerboardRasterCacheImages,
      checkerboardOffscreenLayers: widget.checkerboardOffscreenLayers,
      showSemanticsDebugger: widget.showSemanticsDebugger,
      debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
      actions: widget.actions,
      restorationScopeId: widget.restorationScopeId,
    );
  }
}
