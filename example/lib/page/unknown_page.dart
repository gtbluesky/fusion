import 'package:flutter/material.dart';

class UnknownPage extends StatelessWidget {
  const UnknownPage({Key? key, this.arguments}) : super(key: key);

  final Map<String, dynamic>? arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(arguments?['title'] ?? '未知页面', style: AppBarTheme.of(context).titleTextStyle),
      ),
      body: const Center(
        child: Text('请检查路由'),
      ),
    );
  }
}
