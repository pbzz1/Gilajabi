import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PostTab extends StatefulWidget {
  const PostTab({super.key});

  @override
  State<PostTab> createState() => _PostTab();
}

class _PostTab extends State<PostTab> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://mjchoi1223.github.io/kakao-map-test/kakao_map.html'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주변 시설')),
      body: WebViewWidget(controller: _controller),
    );
  }
}