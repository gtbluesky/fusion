import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FusionRouteInformationParser
    extends RouteInformationParser<RouteSettings> {
  FusionRouteInformationParser();

  @override
  Future<RouteSettings> parseRouteInformation(
      RouteInformation routeInformation) {
    if (kDebugMode) {
      print('routeInformation.location=${routeInformation.location}');
    }
    final parse = DefaultUriParse(Uri.parse(routeInformation.location ?? '/'));
    final initialRoute =
        RouteSettings(name: parse.getName(), arguments: parse.getArguments());
    return SynchronousFuture(initialRoute);
  }
}

abstract class UriParse {
  final Uri _uri;

  UriParse(this._uri);

  String getName();

  Map<String, String>? getArguments();
}

class DefaultUriParse extends UriParse {
  DefaultUriParse(Uri uri) : super(uri);

  @override
  String getName() {
    return _uri.path;
  }

  @override
  Map<String, String>? getArguments() {
    return _uri.queryParameters;
  }
}
