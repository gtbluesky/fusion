import 'package:flutter/material.dart';

import '../channel/fusion_channel.dart';
import '../data/fusion_data.dart';
import '../navigator/fusion_navigator.dart';
import '../navigator/route_information_parser.dart';
import '../navigator/router_delegate.dart';

class FusionApp extends StatefulWidget {
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final RouteInformationProvider? routeInformationProvider;
  final BackButtonDispatcher? backButtonDispatcher;
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
  final Map<ShortcutActivator, Intent>? shortcuts;
  final Map<Type, Action<Intent>>? actions;
  final String? restorationScopeId;
  final ScrollBehavior? scrollBehavior;
  final bool useInheritedMediaQuery;

  FusionApp(
    Map<String, PageFactory> routeMap, {
    Key? key,
    this.scaffoldMessengerKey,
    this.routeInformationProvider,
    this.backButtonDispatcher,
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
    this.shortcuts,
    this.actions,
    this.restorationScopeId,
    this.scrollBehavior,
    this.useInheritedMediaQuery = false,
    Duration transitionDuration = const Duration(milliseconds: 300),
    Duration reverseTransitionDuration = const Duration(milliseconds: 300),
  }) : super(key: key) {
    FusionNavigator.instance.routeInformationParser =
        FusionRouteInformationParser();
    FusionNavigator.instance.routerDelegate = FusionRouterDelegate.instance;
    FusionNavigator.instance.routeMap = routeMap;
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
    FusionChannel.register();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        routeInformationParser: FusionNavigator.instance.routeInformationParser,
        routerDelegate: FusionNavigator.instance.routerDelegate,
        scaffoldMessengerKey: widget.scaffoldMessengerKey,
        routeInformationProvider: widget.routeInformationProvider,
        backButtonDispatcher: widget.backButtonDispatcher,
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
        shortcuts: widget.shortcuts,
        actions: widget.actions,
        restorationScopeId: widget.restorationScopeId,
        scrollBehavior: widget.scrollBehavior,
        useInheritedMediaQuery: widget.useInheritedMediaQuery);
  }
}
