import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fusion/fusion.dart';

class ListPage extends StatefulWidget {
  const ListPage({Key? key, this.args}) : super(key: key);

  final Map<String, dynamic>? args;

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> with FusionPageLifecycleMixin {
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
        title: Text(widget.args?['title'] ?? '未知页面'),
      ),
      body: ListView.builder(
        itemCount: 50,
        itemBuilder: (context, index) {
          return Text('第$index项',
              style: const TextStyle(fontSize: 16, color: Colors.black));
        },
      ),
    );
  }
}
