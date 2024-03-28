import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fusion/fusion.dart';

class BackgroundPage extends StatefulWidget {
  const BackgroundPage({Key? key, this.args}) : super(key: key);

  final Map<String, dynamic>? args;

  @override
  State<BackgroundPage> createState() => _BackgroundPageState();
}

class _BackgroundPageState extends State<BackgroundPage> {
  int get backgroundColor =>
      widget.args?['backgroundColor'] ?? Colors.white.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(backgroundColor),
      appBar: AppBar(
        backgroundColor: Color(backgroundColor),
        title: Text(widget.args?['title'] ??'自定义背景色', style: AppBarTheme.of(context).titleTextStyle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                FusionNavigator.instance.open('/lifecycle', {'title': 'Open'});
              },
              child: const Text(
                'open /lifecycle',
                style: TextStyle(color: Colors.white),
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
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
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
