import 'package:flutter/material.dart';
import 'package:fusion/fusion.dart';
import 'package:fusion_example/page/lifecycle_page.dart';

import 'page/list_page.dart';
import 'page/test_page.dart';
import 'page/unknown_page.dart';

void main() {
  runApp(FusionApp(
    routeMap,
    debugShowCheckedModeBanner: false,
  ));
}

final Map<String, PageFactory> routeMap = {
  '/test': (arguments) => TestPage(arguments: arguments),
  '/list': (arguments) => ListPage(arguments: arguments),
  '/lifecycle': ((arguments) => LifecyclePage(
        arguments: arguments,
      )),
  '/': (arguments) => UnknownPage(arguments: arguments),
};
