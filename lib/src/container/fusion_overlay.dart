import 'package:flutter/material.dart';
import 'package:fusion/src/app/fusion_home.dart';
import 'package:fusion/src/container/fusion_container.dart';
import 'package:fusion/src/container/fusion_page.dart';

class FusionOverlayManager {
  FusionOverlayManager._();
  static final FusionOverlayManager _instance = FusionOverlayManager._();
  static FusionOverlayManager get instance => _instance;

  final _entryList = <FusionOverlayEntry>[];

  final routes = <Route>[];

  Route? get topRoute => routes.isNotEmpty ? routes.last : null;

  Route? get nextRoute => routes.length >= 2 ? routes.elementAt(routes.length - 2) : null;

  void add(FusionContainer container) {
    final entry = FusionOverlayEntry(container);
    _entryList.add(entry);
    overlayKey.currentState?.insert(entry);
  }

  void restore(List<FusionContainer> containers) {
    final entryList = <FusionOverlayEntry>[];
    for (final container in containers) {
      final entry = FusionOverlayEntry(container);
      entryList.add(entry);
    }
    _entryList.addAll(entryList);
    overlayKey.currentState?.insertAll(entryList);
  }

  FusionContainer? remove(String uniqueId) {
    final entry = findEntry(uniqueId);
    if (entry == null) {
      return null;
    }
    _entryList.remove(entry);
    entry.remove();
    return entry.container;
  }

  void switchTop(String uniqueId) {
    if (_entryList.last.uniqueId == uniqueId) {
      return;
    }
    final entry = findEntry(uniqueId);
    if (entry == null) {
      return;
    }
    _entryList.remove(entry);
    _entryList.add(entry);
    entry.remove();
    overlayKey.currentState?.insert(entry);
  }

  FusionOverlayEntry? findEntry(String uniqueId) {
    for (final entry in _entryList) {
      if (entry.uniqueId == uniqueId) {
        return entry;
      }
    }
    return null;
  }

  FusionContainer? findContainer(String uniqueId) {
    for (final entry in _entryList) {
      if (entry.uniqueId == uniqueId) {
        return entry.container;
      }
    }
    return null;
  }

  FusionContainer? findContainerByPage(String routeName) {
    for (final entry in _entryList.reversed) {
      for (final page in entry.container.pages.reversed) {
        if (page.pageEntity.name == routeName) {
          return entry.container;
        }
      }
    }
    return null;
  }

  FusionPage? findPage(Route route) {
    for (final entry in _entryList.reversed) {
      for (final page in entry.container.pages.reversed) {
        if (page.route == route) {
          return page;
        }
      }
    }
    return null;
  }

  FusionContainer? topContainer() {
    return _entryList.isEmpty ? null : _entryList.last.container;
  }

  void addRoute(Route route) {
    routes.add(route);
  }

  void removeRoute(Route route) {
    routes.remove(route);
  }

}

class FusionOverlayEntry extends OverlayEntry {
  final String uniqueId;
  final FusionContainer container;

  FusionOverlayEntry(this.container)
      : uniqueId = container.uniqueId,
        super(
          builder: (_) => FusionContainerWidget(container),
          opaque: true,
          maintainState: true,
        );
}
