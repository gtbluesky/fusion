import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:fusion/src/channel/fusion_channel.dart';
import 'package:fusion/src/constant/fusion_constant.dart';
import 'package:fusion/src/data/fusion_data.dart';
import 'package:fusion/src/navigator/fusion_navigator.dart';
import 'package:fusion/src/navigator/fusion_navigator_delegate.dart';
import 'package:fusion/src/navigator/fusion_navigator_observer.dart';

typedef FusionPageFactory = Widget Function(Map<String, dynamic>? arguments);

class FusionApp extends StatefulWidget {
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final List<NavigatorObserver> navigatorObservers;
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

  FusionApp(
    Map<String, FusionPageFactory> routeMap, {
    Key? key,
    this.scaffoldMessengerKey,
    this.navigatorObservers = const <NavigatorObserver>[],
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
    Duration transitionDuration = const Duration(milliseconds: 300),
    Duration reverseTransitionDuration = const Duration(milliseconds: 300),
  }) : super(key: key) {
    FusionNavigatorDelegate.instance.routeMap = routeMap;
    FusionData.isReused = ui.window.defaultRouteName == kReuseMode;
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
    /// Make sure that the widget in the tree is already mounted.
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _restoreHistoryAfterHotRestart();
    });
    FusionChannel.instance.register();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: widget.scaffoldMessengerKey,
      navigatorObservers: [
        FusionNavigatorObserver.instance,
        ...widget.navigatorObservers
      ],
      home: const Scaffold(backgroundColor: Colors.white),
      builder: widget.builder,
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

  _restoreHistoryAfterHotRestart() async {
    final list = await FusionChannel.instance.restoreHistory();
    if (list.isNotEmpty) {
      for (var element in list) {
        FusionNavigator.instance.restore(element);
      }
    }
  }
}
