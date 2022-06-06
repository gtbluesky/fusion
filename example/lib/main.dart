import 'package:flutter/material.dart';
import 'package:fusion/fusion.dart';

import 'page/lifecycle_page.dart';
import 'page/list_page.dart';
import 'page/test_page.dart';
import 'page/unknown_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FusionApp(
      routeMap,
      debugShowCheckedModeBanner: false,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      theme: ThemeData(
          pageTransitionsTheme:
          const PageTransitionsTheme(builders: _defaultBuilders)),
    );
  }
}


final Map<String, FusionPageFactory> routeMap = {
  '/test': (arguments) => TestPage(arguments: arguments),
  '/list': (arguments) => ListPage(arguments: arguments),
  '/lifecycle': ((arguments) => LifecyclePage(
        arguments: arguments,
      )),
  unknownRoute: (arguments) => UnknownPage(arguments: arguments),
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
