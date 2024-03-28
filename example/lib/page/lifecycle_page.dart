import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fusion/fusion.dart';

class LifecyclePage extends StatefulWidget {
  const LifecyclePage({Key? key, this.arguments}) : super(key: key);

  final Map<String, dynamic>? arguments;

  @override
  State<LifecyclePage> createState() => _LifecyclePageState();
}

class _LifecyclePageState extends State<LifecyclePage>
    implements PageLifecycleListener {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.arguments?['title'] ?? '未知页面',
            style: AppBarTheme.of(context).titleTextStyle),
            backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              child: const Text('push /native_normal_scene'),
              onTap: () {
                FusionNavigator.instance.push('/native_normal_scene', {'title': '12121'});
              },
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('push /test'),
                onTap: () async {
                  final result = await FusionNavigator.instance
                      .push<String?>('/test', {'title': '2'});
                  if (kDebugMode) {
                    print('result=$result');
                  }
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('push /lifecycle'),
                onTap: () async {
                  // await FusionNavigator.instance.pop();
                  final result = await FusionNavigator.instance
                      .push<String?>('/lifecycle', {'title': 'Lifecycle Test'});
                  if (kDebugMode) {
                    print('result=$result');
                  }
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('open /lifecycle'),
                onTap: () async {
                  FusionNavigator.instance
                      .open('/lifecycle', {'title': 'Open'});
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('push /willpop'),
                onTap: () async {
                  final result =
                      await FusionNavigator.instance.push<String?>('/willpop');
                  if (kDebugMode) {
                    print('result=$result');
                  }
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('push /web'),
                onTap: () async {
                  final result =
                      await FusionNavigator.instance.push<String?>('/web');
                  if (kDebugMode) {
                    print('result=$result');
                  }
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('pop'),
                onTap: () {
                  FusionNavigator.instance.pop('test返回结果');
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('replace /list'),
                onTap: () {
                  FusionNavigator.instance
                      .replace('/list', {'title': 'replace success'});
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('remove /lifecycle'),
                onTap: () {
                  FusionNavigator.instance.remove('/lifecycle');
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('platform plugin'),
                onTap: () async {
                  if (Platform.isAndroid) {
                    SystemChannels.platform.invokeMethod(
                        'HapticFeedback.vibrate',
                        'HapticFeedbackType.mediumImpact');
                  } else {
                    SystemChannels.platform.invokeMethod(
                        'SystemSound.play', 'SystemSoundType.click');
                  }
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('custom channel'),
                onTap: () async {
                  final result = await const MethodChannel('custom_channel')
                      .invokeMethod('custom channel');
                  if (kDebugMode) {
                    print('result=$result');
                  }
                }),
            const SizedBox(
              height: 20,
            ),
            const TextField(),
            const SizedBox(
              height: 20,
            ),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // FusionNavigator.instance.sendMessage(
          //     'msg1', {'time': DateTime.now().millisecondsSinceEpoch});
          showDialog(
              context: context,
              builder: (context) {
                return GestureDetector(
                  child: const Text('我是弹窗'),
                  onTap: () {
                    Navigator.of(context).pop();
                    FusionNavigator.instance.pop();
                  },
                );
              });
        },
      ),
    );
  }

  @override
  void onBackground() {
    if (kDebugMode) {
      print('$runtimeType@$hashCode:onBackground');
    }
  }

  @override
  void onForeground() {
    if (kDebugMode) {
      print('$runtimeType@$hashCode:onForeground');
    }
  }

  @override
  void onPageInvisible() {
    if (kDebugMode) {
      print('$runtimeType@$hashCode:onPageInvisible');
    }
  }

  @override
  void onPageVisible() {
    if (kDebugMode) {
      print('$runtimeType@$hashCode:onPageVisible');
    }
  }

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('$runtimeType@$hashCode:initState');
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    if (kDebugMode) {
      print('$runtimeType@$hashCode:deactivate');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PageLifecycleBinding.instance.register(this);
    if (kDebugMode) {
      print('$runtimeType@$hashCode:didChangeDependencies');
    }
  }

  @override
  void dispose() {
    super.dispose();
    PageLifecycleBinding.instance.unregister(this);
    if (kDebugMode) {
      print('$runtimeType@$hashCode:dispose');
    }
  }
}
