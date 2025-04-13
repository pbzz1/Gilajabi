import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _PostTab();
}

class _PostTab extends State<CoursePage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://pbzz1.github.io/Gilajabi/kakao_map.html'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주변 시설')),
      body: WebViewWidget(controller: _controller),
    );
  }
}