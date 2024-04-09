import 'package:flutter/material.dart';

class UnknownPage extends StatelessWidget {
  const UnknownPage({Key? key, this.args}) : super(key: key);

  final Map<String, dynamic>? args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(args?['title'] ?? '未知页面'),
      ),
      body: const Center(
        child: Text('请检查路由'),
      ),
    );
  }
}
