import 'package:flutter/material.dart';
import 'package:fusion/fusion.dart';
import 'package:fusion/log/fusion_log.dart';

class LifecyclePage extends StatefulWidget {
  const LifecyclePage({Key? key, this.arguments}) : super(key: key);

  final Map<String, dynamic>? arguments;

  @override
  State<LifecyclePage> createState() => _LifecyclePageState();
}

class _LifecyclePageState extends State<LifecyclePage>
    implements PageLifecycleObserver {
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
                  FusionLog.log('result=$result');
                }),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                child: const Text('pop'),
                onTap: () {
                  FusionNavigator.instance.pop('我是返回结果');
                }),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onBackground() {
    FusionLog.log('${runtimeType}@${hashCode}:onBackground');
  }

  @override
  void onForeground() {
    FusionLog.log('${runtimeType}@${hashCode}:onForeground');
  }

  @override
  void onPageInvisible() {
    FusionLog.log('${runtimeType}@${hashCode}:onPageInvisible');
  }

  @override
  void onPageVisible() {
    FusionLog.log('${runtimeType}@${hashCode}:onPageVisible');
  }

  @override
  void initState() {
    super.initState();
    FusionLog.log('${runtimeType}@${hashCode}:initState');
  }

  @override
  void deactivate() {
    super.deactivate();
    FusionLog.log('${runtimeType}@${hashCode}:deactivate');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PageLifecycleBinding.instance.register(this);
    FusionLog.log('${runtimeType}@${hashCode}:didChangeDependencies');
  }

  @override
  void dispose() {
    super.dispose();
    PageLifecycleBinding.instance.unregister(this);
    FusionLog.log('${runtimeType}@${hashCode}:dispose');
  }
}
