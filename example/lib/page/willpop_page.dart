import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fusion/fusion.dart';

class WillPopPage extends StatefulWidget {
  const WillPopPage({Key? key}) : super(key: key);

  @override
  State<WillPopPage> createState() => _WillPopPageState();
}

class _WillPopPageState extends State<WillPopPage> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var result = await showDialog<bool>(
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
                      child: const Text('取消（拦截）')),
                  InkWell(
                      onTap: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('确定（不拦截）'))
                ],
              );
            },
            context: context);
        return result ?? true;
      },
      child: Scaffold(
        appBar: AppBar(
          title:
              Text('返回拦截测试页面', style: AppBarTheme.of(context).titleTextStyle),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  FusionNavigator.instance.maybePop('maybePop');
                },
                child: const Text(
                  'maybePop',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  FusionNavigator.instance.pop('pop');
                },
                child: const Text(
                  'pop',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  FusionNavigator.instance.pop(1);
                },
                child: const Text(
                  'pop 1',
                ),
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _count = 0;
            showModalBottomSheet(
                context: context,
                builder: (_) {
                  return WillPopScope(
                    onWillPop: () async {
                      print('_count=${_count}');
                      return _count++ >= 2;
                    },
                    child: SafeArea(
                      child: Container(
                        color: Colors.lightBlue,
                        height: 50,
                      ),
                    ),
                  );
                });
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('$runtimeType@$hashCode:initState');
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (kDebugMode) {
      print('$runtimeType@$hashCode:dispose');
    }
  }
}
