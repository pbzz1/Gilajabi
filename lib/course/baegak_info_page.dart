import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BaegakInfoPage extends StatefulWidget {
  const BaegakInfoPage({Key? key}) : super(key: key);

  @override
  State<BaegakInfoPage> createState() => _BaegakInfoPageState();
}

class _BaegakInfoPageState extends State<BaegakInfoPage> {
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('1코스 백악구간')),
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri("https://www.durunubi.kr/4-2-1-1-walk-mobility-view-detail.do?crs_idx=T_CRS_MNG0000003577"),
          ),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            useOnLoadResource: true,
            mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW, // ✅ 최신 방식
          ),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
        ),
      ),
    );
  }
}
