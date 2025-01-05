import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fusion/fusion.dart';

class DialogPage extends StatefulWidget {
  final Map<String, dynamic>? args;

  const DialogPage({
    super.key,
    this.args,
  });

  @override
  State<DialogPage> createState() => _DialogPageState();
}

class _DialogPageState extends State<DialogPage>
    with FusionPageLifecycleMixin {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
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
                    child: const Text('topPageRouteName'),
                    onTap: () {
                      print(
                          'topPageRouteName=${FusionNavigator.topPageRouteName}');
                    }),
                InkWell(
                    child: const Text('topRouteName'),
                    onTap: () {
                      print('topRouteName=${FusionNavigator.topRouteName}');
                    }),
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
      Navigator.of(context).pop(false);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FusionPageLifecycleManager.instance.register(this);
  }

  @override
  void dispose() {
    super.dispose();
    FusionPageLifecycleManager.instance.unregister(this);
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
    return const SizedBox.shrink();
  }
}
