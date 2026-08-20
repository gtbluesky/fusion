import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion/src/channel/fusion_channel.dart';
import 'package:fusion/src/container/fusion_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('sanitizeForStandardMessageCodec', () {
    test('keeps encodable args unchanged', () {
      final args = <String, dynamic>{
        'title': 'hello',
        'count': 42,
        'flag': true,
        'ratio': 1.5,
        'empty': null,
        'tags': <Object?>['a', 1, false, null],
        'nested': <String, dynamic>{'ok': 1},
      };
      final bytes = Uint8List.fromList([1, 2, 3]);
      args['bytes'] = bytes;

      final sanitized =
          sanitizeForStandardMessageCodec(args) as Map<Object?, Object?>;

      expect(sanitized['title'], 'hello');
      expect(sanitized['count'], 42);
      expect(sanitized['flag'], isTrue);
      expect(sanitized['ratio'], 1.5);
      expect(sanitized['empty'], isNull);
      expect(sanitized['tags'], ['a', 1, false, null]);
      expect(sanitized['nested'], {'ok': 1});
      expect(sanitized['bytes'], same(bytes));
      expect(
        () => const StandardMessageCodec().encodeMessage(sanitized),
        returnsNormally,
      );
    });

    test('omits Function callbacks and other non-encodable values', () {
      void callback() {}
      final args = <String, dynamic>{
        'title': 'hello',
        'onTap': callback,
        'nested': <String, dynamic>{
          'ok': true,
          'cb': (int x) => x,
        },
        'items': <Object?>['a', callback, 'b'],
        'when': DateTime.utc(2026, 1, 13),
      };

      expect(
        () => const StandardMessageCodec().encodeMessage(args),
        throwsArgumentError,
      );

      final sanitized =
          sanitizeForStandardMessageCodec(args) as Map<Object?, Object?>;

      expect(sanitized['title'], 'hello');
      expect(sanitized.containsKey('onTap'), isFalse);
      expect(sanitized.containsKey('when'), isFalse);
      expect(sanitized['nested'], {'ok': true});
      expect(sanitized['items'], ['a', 'b']);
      expect(
        () => const StandardMessageCodec().encodeMessage(sanitized),
        returnsNormally,
      );
    });
  });

  group('FusionChannel.sync', () {
    const hostSync = BasicMessageChannel<Object?>(
      'fusion_channel/host/sync',
      StandardMessageCodec(),
    );

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(hostSync.name, null);
    });

    test('send does not throw when page args include a callback', () async {
      Object? received;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(hostSync.name, (ByteData? message) async {
        received = const StandardMessageCodec().decodeMessage(message);
        return null;
      });

      expect(
        () => FusionChannel.instance.sync('container_1', [
          FusionPageEntity('/index', {
            'title': 'hello',
            'count': 7,
            'onDone': () {},
            'nested': {'keep': 'yes', 'cb': () {}},
          }),
          FusionPageEntity('/list', {'x': 'y'}),
        ]),
        returnsNormally,
      );

      await Future<void>.delayed(Duration.zero);

      expect(received, isA<Map>());
      final payload = received as Map;
      expect(payload['uniqueId'], 'container_1');
      final history = payload['history'] as List;
      expect(history, hasLength(2));
      final args = (history[0] as Map)['args'] as Map;
      expect(args['title'], 'hello');
      expect(args['count'], 7);
      expect(args.containsKey('onDone'), isFalse);
      expect(args['nested'], {'keep': 'yes'});
      expect((history[1] as Map)['args'], {'x': 'y'});
    });
  });
}
