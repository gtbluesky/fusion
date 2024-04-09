import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fusion/fusion.dart';

class NavigatorPage extends StatefulWidget {
  const NavigatorPage({Key? key, this.args}) : super(key: key);

  final Map<String, dynamic>? args;

  @override
  State<NavigatorPage> createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage>
    implements FusionPageLifecycleListener {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.args?['title'] ?? '未知页面'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
                child: const Text('pushNamed /test'),
                onTap: () async {
                  final result =
                      await Navigator.of(context).pushNamed<String?>('/test');
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
                  Navigator.of(context).pop('test返回结果');
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('replace /list'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/list',
                      arguments: {'title': 'replace success'});
                }),
          ],
        ),
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
    FusionPageLifecycleBinding.instance.register(this);
    if (kDebugMode) {
      print('$runtimeType@$hashCode:didChangeDependencies');
    }
  }

  @override
  void dispose() {
    super.dispose();
    FusionPageLifecycleBinding.instance.unregister(this);
    if (kDebugMode) {
      print('$runtimeType@$hashCode:dispose');
    }
  }
}
