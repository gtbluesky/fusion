import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fusion/fusion.dart';

class IndexPage extends StatefulWidget {
  IndexPage({Key? key, this.args}) : super(key: key) {
    _channel = const MethodChannel('fusion');
  }

  final Map<String, dynamic>? args;

  late final MethodChannel _channel;

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage>
    implements FusionNotificationListener, FusionPageLifecycleListener {
  String? msg;

  @override
  void onReceive(String name, Map<String, dynamic>? body) {
    setState(() {
      msg = '$runtimeType@$hashCode, $name, $body';
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FusionNotificationBinding.instance.register(this);
    FusionPageLifecycleBinding.instance.register(this);
  }

  @override
  void dispose() {
    super.dispose();
    FusionNavigator.instance.sendMessage("close");
    FusionNotificationBinding.instance.unregister(this);
    FusionPageLifecycleBinding.instance.unregister(this);
    if (kDebugMode) {
      print('$runtimeType@$hashCode:dispose');
    }
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text(widget.args?['title'] ?? '未知页面',
            style: const TextStyle(color: Colors.black, fontSize: 20)),
      ),
      body: ListView(
        children: [
          InkWell(
            child: const Text('push(adaption) /native_normal_scene'),
            onTap: () {
              FusionNavigator.instance.push(
                '/native_normal_scene',
                routeArgs: {'title': 'Native Normal Scene'},
                routeType: FusionRouteType.adaption,
              );
            },
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
              child: const Text('push(flutter) /index'),
              onTap: () async {
                final result = await FusionNavigator.instance.push<String?>(
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
                // await FusionNavigator.instance.pop();
                final result = await FusionNavigator.instance.push<String?>(
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
              child: const Text('push(flutter) /refresh'),
              onTap: () async {
                FusionNavigator.instance.push(
                  '/refresh',
                  routeType: FusionRouteType.flutter,
                );
              }),
          const SizedBox(
            height: 20,
          ),
          InkWell(
              child: const Text('push(flutterWithContainer) /lifecycle'),
              onTap: () async {
                FusionNavigator.instance.push(
                  '/lifecycle',
                  routeArgs: {'title': 'Lifecycle Page'},
                  routeType: FusionRouteType.flutterWithContainer,
                );
              }),
          const SizedBox(
            height: 20,
          ),
          InkWell(
              child: const Text('push(flutterWithContainer) /background'),
              onTap: () async {
                FusionNavigator.instance.push(
                  '/background',
                  routeArgs: {'backgroundColor': 0xFF546E7A},
                  routeType: FusionRouteType.flutterWithContainer,
                );
              }),
          const SizedBox(
            height: 20,
          ),
          InkWell(
              child: const Text('push(flutter) /navigator'),
              onTap: () async {
                final result = await FusionNavigator.instance.push<String?>(
                  '/navigator',
                  routeArgs: {'title': 'System Navigator'},
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
              child: const Text('push(flutter) /willpop'),
              onTap: () async {
                final result = await FusionNavigator.instance.push(
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
                final result = await FusionNavigator.instance.push<String?>(
                  '/web',
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
                  SystemChannels.platform.invokeMethod('HapticFeedback.vibrate',
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
              child: const Text('fusion plugin'),
              onTap: () async {
                final result =
                    await widget._channel.invokeMethod('getPlatformVersion');
                if (kDebugMode) {
                  print('result=$result');
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
          // InkWell(
          //     child: const Text('show toast'),
          //     onTap: () {
          //       EasyLoading.showToast('This is a toast');
          //     }),
          // const SizedBox(
          //   height: 20,
          // ),
          InkWell(
            child: const Text('show dialog'),
            onTap: () {
              showDialog<bool>(
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
                      ],
                    );
                  },
                  context: context);
            },
          ),
          const SizedBox(
            height: 20,
          ),
          const TextField(),
          const SizedBox(
            height: 20,
          ),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(
            height: 20,
          ),
          Text('onReceive=$msg')
        ],
      ),
    );
  }
}
