import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fusion/fusion.dart';

class TestPage extends StatefulWidget {
  TestPage({Key? key, this.arguments}) : super(key: key) {
    _channel = const MethodChannel('fusion');
  }

  final Map<String, dynamic>? arguments;

  late final MethodChannel _channel;

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage>
    implements PageNotificationListener {
  String? msg;

  @override
  void onReceive(String msgName, Map<String, dynamic>? msgBody) {
    setState(() {
      msg = '$runtimeType@$hashCode, $msgName, $msgBody';
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PageNotificationBinding.instance.register(this);
  }

  @override
  void dispose() {
    super.dispose();
    FusionNavigator.instance.sendMessage("close");
    PageNotificationBinding.instance.unregister(this);
    if (kDebugMode) {
      print('$runtimeType@$hashCode:dispose');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.arguments?['title'] ?? '未知页面',
            style: AppBarTheme.of(context).titleTextStyle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              child: const Text('push /normal'),
              onTap: () {
                FusionNavigator.instance
                    .push('/normal', arguments: {'title': '12121'});
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
                child: const Text('push /lifecycle'),
                onTap: () async {
                  final result = await FusionNavigator.instance.push<String?>(
                      '/lifecycle',
                      arguments: {'title': 'Lifecycle Test'});
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
                child: const Text('plugin'),
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
                  const MethodChannel('custom_channel').invokeMethod('getPlatformVersion');
                  // if (kDebugMode) {
                  //   print('result=$result');
                  // }
                }),
            const SizedBox(
              height: 20,
            ),
            const CircularProgressIndicator(),
            const SizedBox(
              height: 20,
            ),
            Text('onReceive=$msg')
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (_) {
                return SafeArea(
                  child: Container(
                    color: Colors.lightBlue,
                    height: 50,
                  ),
                );
              });
          // if (kDebugMode) {
          //   print('${ModalRoute.of(context).hashCode}');
          // }
          // setState(() {
          //   ++_count;
          // });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
