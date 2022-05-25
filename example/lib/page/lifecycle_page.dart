import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
                child: const Text('pop'),
                onTap: () {
                  FusionNavigator.instance.pop('Lifecycle返回结果');
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('replace'),
                onTap: () {
                  FusionNavigator.instance.replace('/test', arguments: {'title': 'replace success'});
                }),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          FusionNavigator.instance.sendMessage(
              'msg1', msgBody: {'time': DateTime.now().millisecondsSinceEpoch});
          // showDialog(
          //     context: context,
          //     builder: (context) {
          //       return GestureDetector(
          //         child: const Text('我是弹窗'),
          //         onTap: () {
          //           Navigator.of(context).pop();
          //         },
          //       );
          //     });
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
