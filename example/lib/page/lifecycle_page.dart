import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fusion/fusion.dart';

class LifecyclePage extends StatefulWidget {
  const LifecyclePage({Key? key, this.args}) : super(key: key);

  final Map<String, dynamic>? args;

  @override
  State<LifecyclePage> createState() => _LifecyclePageState();
}

class _LifecyclePageState extends State<LifecyclePage>
    implements FusionPageLifecycleListener {
  @override
  Widget build(BuildContext context) {
    print('$runtimeType@$hashCode build');
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
        title: Text(widget.args?['title'] ?? '未知页面'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              child: const Text('push(native) /native_normal'),
              onTap: () {
                FusionNavigator.push(
                  '/native_normal',
                  routeArgs: {'title': 'Native Normal Scene'},
                  routeType: FusionRouteType.native,
                );
              },
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('push(flutterWithContainer) /index'),
                onTap: () async {
                  final result = await FusionNavigator.push<String?>(
                    '/index',
                    routeArgs: {'title': 'Index Page'},
                    routeType: FusionRouteType.flutterWithContainer,
                  );
                  if (kDebugMode) {
                    print('push(flutterWithContainer) /index result=$result');
                  }
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('push(flutter) /index'),
                onTap: () async {
                  final result = await FusionNavigator.push<String?>(
                    '/index',
                    routeArgs: {'title': 'Index Page'},
                    routeType: FusionRouteType.flutter,
                  );
                  if (kDebugMode) {
                    print('result=$result');
                  }
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('push(flutter) /lifecycle'),
                onTap: () async {
                  // await FusionNavigator.pop();
                  final result = await FusionNavigator.push<String?>(
                    '/lifecycle',
                    routeArgs: {'title': 'Lifecycle Page'},
                    routeType: FusionRouteType.flutter,
                  );
                  if (kDebugMode) {
                    print('result=$result');
                  }
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('push(flutterWithContainer) /lifecycle'),
                onTap: () async {
                  FusionNavigator.push(
                    '/lifecycle',
                    routeArgs: {'title': 'Lifecycle Page'},
                    routeType: FusionRouteType.flutterWithContainer,
                  );
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('push(flutter) /willpop'),
                onTap: () async {
                  final result = await FusionNavigator.push<String?>(
                    '/willpop',
                    routeType: FusionRouteType.flutter,
                  );
                  if (kDebugMode) {
                    print('result=$result');
                  }
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('push(flutter) /web'),
                onTap: () async {
                  final result = await FusionNavigator.push<String?>('/web',
                      routeType: FusionRouteType.flutter);
                  if (kDebugMode) {
                    print('result=$result');
                  }
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              child: const Text('show dialog'),
              onTap: () async {
                await showDialog<bool>(
                    useRootNavigator: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: const RoundedRectangleBorder(),
                        backgroundColor: Colors.red,
                        elevation: 0,
                        title: const Text('提示'),
                        content: const Text('确定要退出吗？'),
                        actions: [
                          InkWell(
                              onTap: () {
                                Navigator.of(context).pop(false);
                              },
                              child: const Text('关闭')),
                          InkWell(
                              child: const Text('push(flutter) /lifecycle'),
                              onTap: () async {
                                FusionNavigator.push(
                                  '/lifecycle',
                                  routeType: FusionRouteType.flutter,
                                );
                              }),
                          InkWell(
                              child: const Text('push(flutter) /index'),
                              onTap: () async {
                                FusionNavigator.push(
                                  '/index',
                                  routeType: FusionRouteType.flutter,
                                );
                              }),
                        ],
                      );
                    },
                    context: context);
                print('dilog pop');
              },
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('pop'),
                onTap: () {
                  FusionNavigator.pop('test返回结果');
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('popUntil /index'),
                onTap: () {
                  FusionNavigator.popUntil(
                    '/index',
                  );
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('replace /list'),
                onTap: () {
                  FusionNavigator.replace(
                      '/list', {'title': 'replace success'});
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('remove /lifecycle'),
                onTap: () {
                  FusionNavigator.remove('/lifecycle');
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('send event'),
                onTap: () {
                  FusionEventManager.instance.send('custom_event',
                      args: {'time': DateTime.now().millisecondsSinceEpoch});
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
                  final result =
                      await const MethodChannel('container_related_channel')
                          .invokeMethod('container related channel');
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
          showDialog(
              context: context,
              builder: (context) {
                return GestureDetector(
                  child: const Text('我是弹窗'),
                  onTap: () {
                    Navigator.of(context).pop();
                    FusionNavigator.pop();
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
    FusionPageLifecycleManager.instance.register(this);
    if (kDebugMode) {
      print('$runtimeType@$hashCode:didChangeDependencies');
    }
  }

  @override
  void dispose() {
    super.dispose();
    FusionPageLifecycleManager.instance.unregister(this);
    if (kDebugMode) {
      print('$runtimeType@$hashCode:dispose');
    }
  }
}
