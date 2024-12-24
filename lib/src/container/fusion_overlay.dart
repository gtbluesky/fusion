import 'dart:collection';

import 'package:flutter/material.dart';
import '../app/fusion_home.dart';
import '../container/fusion_container.dart';
import '../container/fusion_page.dart';
import '../navigator/fusion_navigator_observer.dart';

class FusionOverlayManager {
  FusionOverlayManager._();
  static final FusionOverlayManager _instance = FusionOverlayManager._();
  static FusionOverlayManager get instance => _instance;

  final _entryList = <FusionOverlayEntry>[];

  final rootRoutes = <Route>[];

  List<Route> get containerRoutes {
    return containerRoutesMap.values.expand((e) => e).toList();
  }

  final containerRoutesMap = LinkedHashMap<String, List<Route>>.from({});

  List<FusionContainer> get containers =>
      _entryList.map((e) => e.container).toList();

  Route? get topRoute {
    if (rootRoutes.isNotEmpty) {
      return rootRoutes.last;
    }
    if (containerRoutes.isNotEmpty) {
      return containerRoutes.last;
    }
    return null;
  }

  Route? get topPageRoute {
    final it = containerRoutes.whereType<PageRoute>();
    return it.isNotEmpty ? it.last : null;
  }

  Route? get nextPageRoute {
    final it = containerRoutes.whereType<PageRoute>();
    return it.length >= 2 ? it.elementAt(it.length - 2) : null;
  }

  void add(FusionContainer container) {
    containerRoutesMap[container.uniqueId] = [];
    final entry = FusionOverlayEntry(container);
    _entryList.add(entry);
    overlayKey.currentState?.insert(entry);
  }

  void restore(List<FusionContainer> containers) {
    final entryList = <FusionOverlayEntry>[];
    for (final container in containers) {
      containerRoutesMap[container.uniqueId] = [];
      final entry = FusionOverlayEntry(container);
      entryList.add(entry);
    }
    _entryList.addAll(entryList);
    overlayKey.currentState?.insertAll(entryList);
  }

  bool remove(String uniqueId) {
    final entry = findEntry(uniqueId);
    if (entry == null) {
      return false;
    }
    _entryList.remove(entry);
    entry.remove();
    containerRoutesMap.remove(uniqueId)?.forEach((route) {
      FusionNavigatorObserverManager.instance.navigatorObservers
          ?.forEach((observer) {
        observer.didRemove(route, null);
      });
    });
    return true;
  }

  void switchTop(String uniqueId) {
    if (_entryList.isEmpty || _entryList.last.uniqueId == uniqueId) {
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

  FusionContainer? findContainerByRoute(Route route) {
    String? uniqueId;
    containerRoutesMap.forEach((k, v) {
      for (final r in v) {
        if (r == route) {
          uniqueId = k;
        }
      }
    });
    if (uniqueId == null) {
      return null;
    }
    return findContainer(uniqueId!);
  }

  FusionContainer? findContainerByRouteName(String routeName) {
    String? uniqueId;
    containerRoutesMap.forEach((k, v) {
      for (final route in v) {
        if (route.settings.name == routeName) {
          uniqueId = k;
        }
      }
    });
    if (uniqueId == null) {
      return null;
    }
    return findContainer(uniqueId!);
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

  FusionPage? findPageByName(String routeName) {
    for (final entry in _entryList.reversed) {
      for (final page in entry.container.pages.reversed) {
        if (page.pageEntity.name == routeName) {
          return page;
        }
      }
    }
    return null;
  }

  FusionContainer? topContainer() {
    return _entryList.isEmpty ? null : _entryList.last.container;
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
