import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HeunginjimunInfoPage extends StatefulWidget {
  const HeunginjimunInfoPage({Key? key}) : super(key: key);

  @override
  State<HeunginjimunInfoPage> createState() => _HeunginjimunInfoPageState();
}

class _HeunginjimunInfoPageState extends State<HeunginjimunInfoPage> {
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3코스 흥인지문구간')),
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(
              "https://www.durunubi.kr/4-2-1-1-walk-mobility-view-detail.do?crs_idx=T_CRS_MNG0000005210",
            ),
          ),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            useOnLoadResource: true,
            mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
          ),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
        ),
      ),
    );
  }
}
