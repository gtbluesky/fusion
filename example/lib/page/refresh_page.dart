import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fusion/fusion.dart';

class RefreshPage extends StatefulWidget {
  const RefreshPage({Key? key, this.args}) : super(key: key);

  final Map<String, dynamic>? args;

  @override
  State<RefreshPage> createState() => _RefreshPageState();
}

class _RefreshPageState extends State<RefreshPage>
    with FusionPageLifecycleMixin {
  int _count = 1;
  late EasyRefreshController _controller;

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
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.args?['title'] ?? 'EasyRefresh'),
      ),
      body: EasyRefresh(
        controller: _controller,
        header: const ClassicHeader(),
        footer: const ClassicFooter(),
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          if (!mounted) {
            return;
          }
          setState(() {
            _count = 1;
          });
          _controller.finishRefresh();
          _controller.resetFooter();
        },
        onLoad: () async {
          await Future.delayed(const Duration(seconds: 1));
          if (!mounted) {
            return;
          }
          setState(() {
            _count += 1;
          });
          _controller.finishLoad(
              _count >= 2 ? IndicatorResult.noMore : IndicatorResult.success);
        },
        child: ListView.builder(
          itemBuilder: (context, index) {
            if (index == 0) {
              return InkWell(
                child: const Text('push(adaption) /native_normal'),
                onTap: () {
                  FusionNavigator.push(
                    '/native_normal',
                    routeArgs: {'title': 'Native Normal Scene'},
                    routeType: FusionRouteType.adaption,
                  );
                },
              );
            } else {
              return Card(
                child: Container(
                  alignment: Alignment.center,
                  height: 80,
                  child: Text('${index + 1}'),
                ),
              );
            }
          },
          itemCount: _count,
        ),
      ),
    );
  }
}
