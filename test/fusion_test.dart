import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion/src/container/fusion_container.dart';
import 'package:fusion/src/container/fusion_page.dart';
import 'package:fusion/src/data/fusion_data.dart';
import 'package:fusion/src/navigator/fusion_navigator_delegate.dart';
import 'package:fusion/src/navigator/fusion_navigator_observer.dart';

void main() {
  late _RecordingObserver recordingObserver;
  late FusionNavigatorObserver fusionObserver;

  Route<dynamic> _route(String name) {
    return MaterialPageRoute<void>(
      settings: RouteSettings(name: name),
      builder: (_) => const SizedBox.shrink(),
    );
  }

  setUp(() {
    FusionNavigatorObserverManager.instance.debugReset();
    recordingObserver = _RecordingObserver();
    FusionNavigatorObserverManager.instance.navigatorObservers = [
      recordingObserver,
    ];
    fusionObserver = FusionNavigatorObserver();
    FusionNavigatorDelegate.instance.routeMap = {
      '/a': (_) => const Text('A'),
      '/b': (_) => const Text('B'),
      '/c': (_) => const Text('C'),
    };
    FusionData.transitionDuration = Duration.zero;
    FusionData.reverseTransitionDuration = Duration.zero;
  });

  tearDown(() {
    FusionNavigatorObserverManager.instance.debugReset();
    FusionNavigatorDelegate.instance.routeMap = null;
  });

  group('FusionNavigatorObserver replace wiring', () {
    test('replace notifies didReplace and does not forward didRemove', () {
      final oldRoute = _route('/a');
      final newRoute = _route('/b');

      FusionNavigatorObserverManager.instance.beginReplace(
        oldRoute: oldRoute,
        newRoute: newRoute,
      );
      fusionObserver.didRemove(oldRoute, null);
      fusionObserver.didPush(newRoute, null);

      expect(recordingObserver.events, ['didReplace']);
      expect(recordingObserver.lastOldRoute, oldRoute);
      expect(recordingObserver.lastNewRoute, newRoute);
    });

    test('replace notifies didReplace even when only didRemove fires', () {
      final oldRoute = _route('/a');
      final newRoute = _route('/b');

      FusionNavigatorObserverManager.instance.beginReplace(
        oldRoute: oldRoute,
        newRoute: newRoute,
      );
      fusionObserver.didRemove(oldRoute, null);

      expect(recordingObserver.events, ['didReplace']);
      expect(recordingObserver.lastOldRoute, oldRoute);
      expect(recordingObserver.lastNewRoute, newRoute);
    });

    test('unrelated didRemove is still forwarded', () {
      final oldRoute = _route('/a');
      final newRoute = _route('/b');
      final otherRoute = _route('/c');

      FusionNavigatorObserverManager.instance.beginReplace(
        oldRoute: oldRoute,
        newRoute: newRoute,
      );
      fusionObserver.didRemove(otherRoute, null);

      expect(recordingObserver.events, ['didRemove']);
    });

    test('native didReplace is forwarded once', () {
      final oldRoute = _route('/a');
      final newRoute = _route('/b');

      FusionNavigatorObserverManager.instance.beginReplace(
        oldRoute: oldRoute,
        newRoute: newRoute,
      );
      fusionObserver.didReplace(newRoute: newRoute, oldRoute: oldRoute);

      expect(recordingObserver.events, ['didReplace']);
      expect(recordingObserver.lastOldRoute, oldRoute);
      expect(recordingObserver.lastNewRoute, newRoute);
    });
  });

  testWidgets(
    'FusionContainer.replace notifies didReplace instead of only didRemove',
    (tester) async {
      final pageA = FusionPage.createPage('/a', null, false);
      final container = FusionContainer('container-1', pageA);

      await tester.pumpWidget(
        MaterialApp(
          home: FusionContainerWidget(container),
        ),
      );
      await tester.pump();
      recordingObserver.events.clear();

      final pageB = FusionPage.createPage('/b', null, false);
      await container.replace(pageB);
      await tester.pump();

      expect(recordingObserver.events, ['didReplace']);
      expect(recordingObserver.lastOldRoute, pageA.route);
      expect(recordingObserver.lastNewRoute, pageB.route);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('A'), findsNothing);
    },
  );
}

class _RecordingObserver extends NavigatorObserver {
  final List<String> events = [];
  Route<dynamic>? lastNewRoute;
  Route<dynamic>? lastOldRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    events.add('didPush');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    events.add('didPop');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    events.add('didRemove');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    events.add('didReplace');
    lastNewRoute = newRoute;
    lastOldRoute = oldRoute;
  }
}
