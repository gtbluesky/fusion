import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FusionRouteInformationParser
    extends RouteInformationParser<Map<String, dynamic>> {

  @override
  Future<Map<String, dynamic>> parseRouteInformation(
      RouteInformation routeInformation) {
    final parse = DefaultUriParse(Uri.parse(routeInformation.location ?? '/'));
    final arguments = parse.getArguments();
    final initialRoute = {
      'name': parse.getName(),
      'arguments': arguments,
      'uniqueId': arguments?['uniqueId']
    };
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
