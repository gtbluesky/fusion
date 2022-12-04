import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fusion/fusion.dart';
import 'package:fusion_example/page/background_page.dart';
import 'package:fusion_example/page/lifecycle_page.dart';
import 'package:fusion_example/page/list_page.dart';
import 'package:fusion_example/page/navigator_page.dart';
import 'package:fusion_example/page/test_page.dart';
import 'package:fusion_example/page/transparent_page.dart';
import 'package:fusion_example/page/unknown_page.dart';
import 'package:fusion_example/page/web_page.dart';
import 'package:fusion_example/page/willpop_page.dart';

void main() {
  print('defaultRouteName=${ui.window.defaultRouteName}');
  Fusion.instance.install();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return FusionApp(
    //   routeMap: routeMap,
    //   customRouteMap: customRouteMap,
    //   debugShowCheckedModeBanner: false,
    //   transitionDuration: const Duration(milliseconds: 400),
    //   reverseTransitionDuration: const Duration(milliseconds: 400),
    //   theme: ThemeData(
    //       pageTransitionsTheme:
    //       const PageTransitionsTheme(builders: _defaultBuilders)),
    // );
    return ScreenUtilInit(
      designSize: const Size(375, 667),
      minTextAdapt: true,
      builder: (_, __) => FusionApp(
        routeMap: routeMap,
        customRouteMap: customRouteMap,
        debugShowCheckedModeBanner: false,
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        theme: ThemeData(
            pageTransitionsTheme:
                const PageTransitionsTheme(builders: _defaultBuilders)),
      ),
    );
  }
}

final Map<String, FusionPageFactory> routeMap = {
  '/test': (arguments) => TestPage(arguments: arguments),
  '/list': (arguments) => ListPage(arguments: arguments),
  '/lifecycle': (arguments) => LifecyclePage(arguments: arguments),
  '/willpop': ((_) => const WillPopPage()),
  '/web': (_) => const WebPage(),
  '/transparent': (arguments) => TransparentPage(arguments: arguments),
  '/background': (arguments) => BackgroundPage(arguments: arguments),
  kUnknownRoute: (arguments) => UnknownPage(arguments: arguments),
};

final Map<String, FusionPageCustomFactory> customRouteMap = {
  '/navigator': (settings) => PageRouteBuilder(
      opaque: false,
      settings: settings,
      pageBuilder: (_, __, ___) => NavigatorPage(
          arguments: settings.arguments as Map<String, dynamic>?)),
};

const Map<TargetPlatform, PageTransitionsBuilder> _defaultBuilders =
    <TargetPlatform, PageTransitionsBuilder>{
  TargetPlatform.android: SlidePageTransitionsBuilder(),
  TargetPlatform.iOS: CupertinoPageTransitionsBuilder()
};

class SlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const SlidePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    final TextDirection textDirection = Directionality.of(context);
    return SlideTransition(
      transformHitTests: false,
      textDirection: textDirection,
      position: CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.linearToEaseOut,
        reverseCurve: Curves.easeInToLinear,
      ).drive(_kMiddleLeftTween),
      child: SlideTransition(
        textDirection: textDirection,
        position: CurvedAnimation(
          parent: animation,
          curve: Curves.linearToEaseOut,
          reverseCurve: Curves.easeInToLinear,
        ).drive(_kRightMiddleTween),
        child: child,
      ),
    );
  }
}

final Animatable<Offset> _kRightMiddleTween = Tween<Offset>(
  begin: const Offset(1.0, 0.0),
  end: Offset.zero,
);

final Animatable<Offset> _kMiddleLeftTween = Tween<Offset>(
  begin: Offset.zero,
  end: const Offset(-1.0 / 3.0, 0.0),
);
