import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:gilajabi/course/tracking/stamp_points.dart';
import 'package:gilajabi/course/tracking/course_tracking_page.dart'; // baegakStampPoints 포함

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
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri("https://www.durunubi.kr/4-2-1-1-walk-mobility-view-detail.do?crs_idx=T_CRS_MNG0000003577"),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Builder(
              builder: (context) {
                final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.grey : Theme.of(context).primaryColor,
                    foregroundColor: isDarkMode ? Colors.black : Colors.white,
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseTrackingPage(
                          courseName: '1코스 백악구간',
                          polylineJsonFile: 'baegak_path.json',
                          stampPoints: baegakStampPoints,
                        ),
                      ),
                    );
                  },
                  child: const Text("이 코스 선택"),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
