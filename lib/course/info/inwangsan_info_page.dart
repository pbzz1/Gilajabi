import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:gilajabi/course/tracking/stamp_points.dart';
import 'package:gilajabi/course/tracking/course_tracking_page.dart';

class InwangsanInfoPage extends StatefulWidget {
  const InwangsanInfoPage({Key? key}) : super(key: key);

  @override
  State<InwangsanInfoPage> createState() => _InwangsanInfoPageState();
}

class _InwangsanInfoPageState extends State<InwangsanInfoPage> {
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('6코스 인왕산구간')),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri("https://www.durunubi.kr/4-2-1-1-walk-mobility-view-detail.do?crs_idx=T_CRS_MNG0000003579"),
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
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CourseTrackingPage(
                      courseName: '6코스 인왕산구간',
                      polylineJsonFile: 'inwangsan_path.json', // ✅ 여기를 JSON 파일명으로 변경
                      stampPoints: inwangsanStampPoints, // ✅ stamp_points.dart에서 불러온 리스트
                    ),
                  ),
                );
              },
              child: const Text("이 코스 선택"),
            ),
          )
        ],
      ),
    );
  }
}