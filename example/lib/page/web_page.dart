import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fusion/fusion.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPage extends StatefulWidget {
  const WebPage({super.key, this.args});

  final Map<String, dynamic>? args;

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (kDebugMode) {
              print('progress=$progress');
            }
          },
          onPageStarted: (String url) {
            if (kDebugMode) {
              print('onPageStarted: url=$url');
            }
          },
          onPageFinished: (String url) {
            if (kDebugMode) {
              print('onPageFinished: url=$url');
            }
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://bilibili.com'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: GestureDetector(
        child: Text(widget.args?['title'] ?? 'Flutter WebView'),
        onTap: () {
          // FusionNavigator.push('/web', routeType: FusionRouteType.flutterWithContainer);
          FusionNavigator.push('/refresh',
              routeType: FusionRouteType.flutterWithContainer);
        },
      )),
      body: WebViewWidget(controller: controller),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (kDebugMode) {
      print('$runtimeType@$hashCode:dispose');
    }
  }
}
