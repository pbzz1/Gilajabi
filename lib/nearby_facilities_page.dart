import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io'; // Android WebView 초기화용

class NearbyFacilitiesPage extends StatefulWidget {
  const NearbyFacilitiesPage({super.key});

  @override
  State<NearbyFacilitiesPage> createState() => _NearbyFacilitiesPageState();
}

class _NearbyFacilitiesPageState extends State<NearbyFacilitiesPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
    _controller = WebViewController()
      ..loadFlutterAsset('assets/html/kakao_map.html')
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주변 시설')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
