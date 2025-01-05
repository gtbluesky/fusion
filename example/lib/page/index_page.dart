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

class _IndexPageState extends State<IndexPage> with FusionPageLifecycleMixin {
  String? msg;

  void onReceive(Map<String, dynamic>? args) {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) {
        return;
      }
      setState(() {
        msg = '$runtimeType@$hashCode, $args';
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FusionEventManager.instance.register('custom_event', onReceive);
  }

  @override
  void dispose() {
    super.dispose();
    FusionEventManager.instance.unregister('custom_event');
    if (kDebugMode) {
      print('$runtimeType@$hashCode:dispose');
    }
  }

  // @override
  // void onBackground() {
  //   if (kDebugMode) {
  //     print('$runtimeType@$hashCode:onBackground');
  //   }
  // }

  // @override
  // void onForeground() {
  //   if (kDebugMode) {
  //     print('$runtimeType@$hashCode:onForeground');
  //   }
  // }

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
    print('$runtimeType@$hashCode:build');
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
        title: Text(
          widget.args?['title'] ?? '未知页面',
        ),
      ),
      body: ListView(
        children: [
          InkWell(
            child: const Text('push(adaption) /native_normal'),
            onTap: () {
              FusionNavigator.push(
                '/native_normal',
                routeArgs: {'title': 'Native Normal Scene'},
                routeType: FusionRouteType.adaption,
              );
            },
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
              child: const Text('push(adaption) /index'),
              onTap: () async {
                final result = await FusionNavigator.push<String?>(
                  '/index',
                  routeArgs: {'title': 'Index Page'},
                  routeType: FusionRouteType.adaption,
                );
                if (kDebugMode) {
                  print('push(flutter) /index result=$result');
                }
              }),
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
              child: const Text('push(flutter) /lifecycle'),
              onTap: () async {
                // await FusionNavigator.pop();
                final result = await FusionNavigator.push<String?>(
                  '/lifecycle',
                  routeArgs: {'title': 'Lifecycle Page'},
                  routeType: FusionRouteType.flutter,
                );
                if (kDebugMode) {
                  print('push(flutter) /lifecycle result=$result');
                }
              }),
          const SizedBox(
            height: 20,
          ),
          InkWell(
              child: const Text('push(flutter) /refresh'),
              onTap: () async {
                FusionNavigator.push(
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
              child: const Text('push(flutterWithContainer) /background'),
              onTap: () async {
                FusionNavigator.push(
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
                final result = await FusionNavigator.push<String?>(
                  '/navigator',
                  routeArgs: {'title': 'System Navigator'},
                  routeType: FusionRouteType.flutter,
                );
                if (kDebugMode) {
                  print('push(flutter) /navigator result=$result');
                }
              }),
          const SizedBox(
            height: 20,
          ),
          InkWell(
              child: const Text('push(flutter) /willpop'),
              onTap: () async {
                final result = await FusionNavigator.push(
                  '/willpop',
                  routeType: FusionRouteType.flutter,
                );
                if (kDebugMode) {
                  print('push(flutter) /willpop result=$result');
                }
              }),
          const SizedBox(
            height: 20,
          ),
          InkWell(
              child: const Text('push(flutterWithContainer) /transparent'),
              onTap: () async {
                final result = await FusionNavigator.push(
                  '/transparent',
                  routeArgs: {
                    'title': 'Transparent Flutter Page',
                    'transparent': true
                  },
                  routeType: FusionRouteType.flutterWithContainer,
                );
                if (kDebugMode) {
                  print(
                      'push(flutterWithContainer) /transparent result=$result');
                }
              }),
          const SizedBox(
            height: 20,
          ),
          InkWell(
              child: const Text('push(flutter) /web'),
              onTap: () async {
                final result = await FusionNavigator.push<String?>(
                  '/web',
                  routeType: FusionRouteType.flutter,
                );
                if (kDebugMode) {
                  print('push(flutter) /web result=$result');
                }
              }),
          const SizedBox(
            height: 20,
          ),
          InkWell(
              child: const Text('pushAndClear /lifecycle'),
              onTap: () async {
                final result = await FusionNavigator.pushAndClear<String?>(
                  '/lifecycle',
                  routeArgs: {'title': 'Lifecycle Page'},
                );
                if (kDebugMode) {
                  print('pushAndClear /lifecycle result=$result');
                }
              }),
          const SizedBox(
            height: 20,
          ),
          InkWell(
              child: const Text('topPageRouteName'),
              onTap: () {
                print('topPageRouteName=${FusionNavigator.topPageRouteName}');
              }),
          const SizedBox(
            height: 20,
          ),
          InkWell(
              child: const Text('topRouteName'),
              onTap: () {
                print('topRouteName=${FusionNavigator.topRouteName}');
              }),
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
              child: const Text('popUntil /lifecycle'),
              onTap: () {
                FusionNavigator.popUntil(
                  '/lifecycle',
                );
              }),
          const SizedBox(
            height: 20,
          ),
          InkWell(
              child: const Text('replace /list'),
              onTap: () {
                FusionNavigator.replace('/list', {'title': 'replace success'});
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
              child: const Text('remove /test-dialog'),
              onTap: () {
                FusionNavigator.remove('/test-dialog');
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
                  print('fusion plugin result=$result');
                }
              }),
          const SizedBox(
            height: 20,
          ),
          InkWell(
              child: const Text('container_related_channel'),
              onTap: () async {
                final result =
                    await const MethodChannel('container_related_channel')
                        .invokeMethod('container_related_channel');
                if (kDebugMode) {
                  print('container_related_channel result=$result');
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
                  useRootNavigator: false,
                  barrierDismissible: false,
                  routeSettings: const RouteSettings(name: '/test-dialog'),
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
            },
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
              child: const Text('push(flutter) show dialog'),
              onTap: () {
                FusionNavigator.push('/dialog_page',
                    routeArgs: {'transparent': true},
                    routeType: FusionRouteType.flutter);
              }),
          const SizedBox(
            height: 20,
          ),
          InkWell(
              child: const Text('push(flutterWithContainer) show dialog'),
              onTap: () {
                FusionNavigator.push('/dialog_page',
                    routeArgs: {'transparent': true},
                    routeType: FusionRouteType.flutterWithContainer);
              }),
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
