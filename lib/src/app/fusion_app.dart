import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../app/fusion_home.dart';
import '../data/fusion_data.dart';
import '../data/fusion_state.dart';
import '../fusion.dart';
import '../interceptor/fusion_interceptor.dart';
import '../navigator/fusion_navigator_delegate.dart';
import '../navigator/fusion_navigator_observer.dart';

typedef FusionPageFactory = Widget Function(Map<String, dynamic>? args);
typedef FusionPageCustomFactory = PageRoute Function(RouteSettings settings);

/// Default App Widget instead of MaterialApp.
class FusionApp extends StatefulWidget {
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final TransitionBuilder? builder;
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
  final List<NavigatorObserver>? navigatorObservers;
  final List<FusionInterceptor>? interceptors;

  FusionApp({
    Map<String, FusionPageFactory>? routeMap,
    Map<String, FusionPageCustomFactory>? customRouteMap,
    Key? key,
    this.scaffoldMessengerKey,
    this.builder,
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
    this.navigatorObservers,
    this.interceptors,
    Duration transitionDuration = const Duration(milliseconds: 300),
    Duration reverseTransitionDuration = const Duration(milliseconds: 300),
  }) : super(key: key) {
    assert(routeMap != null || customRouteMap != null);
    FusionNavigatorDelegate.instance.routeMap = routeMap;
    FusionNavigatorDelegate.instance.customRouteMap = customRouteMap;
    FusionData.transitionDuration = transitionDuration;
    FusionData.reverseTransitionDuration = reverseTransitionDuration;
    FusionNavigatorObserverManager.instance.navigatorObservers =
        navigatorObservers;
    if (interceptors != null) {
      Fusion.instance.interceptors.addAll(interceptors!);
    }
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
      FusionJobQueue.instance.mounted();
      if (!kDebugMode || FusionState.isRestoring) {
        return;
      }
      FusionNavigatorDelegate.instance.restoreAfterHotRestart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [FusionRootNavigatorObserver()],
      scaffoldMessengerKey: widget.scaffoldMessengerKey,
      builder: widget.builder,
      home: const FusionHome(),
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
