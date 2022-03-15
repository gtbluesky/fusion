import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fusion/fusion.dart';

class TestPage extends StatelessWidget {
  TestPage({Key? key, this.arguments}) : super(key: key) {
    _channel = const MethodChannel('fusion');
  }

  final Map<String, dynamic>? arguments;

  late final MethodChannel _channel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(arguments?['title'] ?? '未知页面',
            style: AppBarTheme.of(context).titleTextStyle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              child: const Text('push /normal'),
              onTap: () {
                FusionNavigator.instance.push('/normal', arguments: {'title': '12121'});
              },
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('push /test'),
                onTap: () async {
                  final result = await FusionNavigator.instance
                      .push<String?>('/test', arguments: {'title': '2'});
                  if (kDebugMode) {
                    print('result=$result');
                  }
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('pop /test'),
                onTap: () {
                  FusionNavigator.instance.pop('我是返回结果');
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('plugin'),
                onTap: () async {
                  if (kDebugMode) {
                    final result = await _channel.invokeMethod('getPlatformVersion');
                    print('result=$result');
                  }
                })
          ],
        ),
      ),
    );
  }
}
