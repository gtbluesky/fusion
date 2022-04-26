import 'package:flutter/material.dart';

class UnknownPage extends StatelessWidget {
  const UnknownPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('未知页面', style: AppBarTheme.of(context).titleTextStyle),
      ),
      body: const Center(
        child: Text('请检查路由'),
      ),
    );
  }
}
