import 'package:flutter/material.dart';

import '../channel/fusion_channel.dart';
import '../navigator/fusion_navigator.dart';
import '../navigator/route_information_parser.dart';
import '../navigator/router_delegate.dart';

class FusionApp extends StatelessWidget {
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
  }) : super(key: key) {
    FusionNavigator.instance.routeInformationParser =
        FusionRouteInformationParser();
    FusionNavigator.instance.routerDelegate = FusionRouterDelegate();
    FusionNavigator.instance.routeMap = routeMap;
  }

  @override
  Widget build(BuildContext context) {
    FusionChannel.register();
    return MaterialApp.router(
        routeInformationParser: FusionNavigator.instance.routeInformationParser,
        routerDelegate: FusionNavigator.instance.routerDelegate,
        scaffoldMessengerKey: scaffoldMessengerKey,
        routeInformationProvider: routeInformationProvider,
        backButtonDispatcher: backButtonDispatcher,
        builder: builder,
        title: title,
        onGenerateTitle: onGenerateTitle,
        color: color,
        theme: theme,
        darkTheme: darkTheme,
        highContrastTheme: highContrastTheme,
        highContrastDarkTheme: highContrastDarkTheme,
        themeMode: themeMode,
        locale: locale,
        localizationsDelegates: localizationsDelegates,
        localeListResolutionCallback: localeListResolutionCallback,
        localeResolutionCallback: localeResolutionCallback,
        supportedLocales: supportedLocales,
        debugShowMaterialGrid: debugShowMaterialGrid,
        showPerformanceOverlay: showPerformanceOverlay,
        checkerboardRasterCacheImages: checkerboardRasterCacheImages,
        checkerboardOffscreenLayers: checkerboardOffscreenLayers,
        showSemanticsDebugger: showSemanticsDebugger,
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        shortcuts: shortcuts,
        actions: actions,
        restorationScopeId: restorationScopeId,
        scrollBehavior: scrollBehavior,
        useInheritedMediaQuery: useInheritedMediaQuery);
  }
}
