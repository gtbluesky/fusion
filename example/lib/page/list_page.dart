import 'package:flutter/material.dart';

class ListPage extends StatelessWidget {
  const ListPage({Key? key, this.arguments}) : super(key: key);

  final Map<String, dynamic>? arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(arguments?['title'] ?? '未知页面',
            style: AppBarTheme.of(context).titleTextStyle),
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
