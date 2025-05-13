import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../tracking/stamp_points.dart';
import '../tracking/course_tracking_page.dart';

class SungnyemunInfoPage extends StatefulWidget {
  const SungnyemunInfoPage({Key? key}) : super(key: key);

  @override
  State<SungnyemunInfoPage> createState() => _SungnyemunInfoPageState();
}

class _SungnyemunInfoPageState extends State<SungnyemunInfoPage> {
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('5코스 숭례문구간')),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri("https://www.durunubi.kr/4-2-1-1-walk-mobility-view-detail.do?crs_idx=T_CRS_MNG0000005211"),
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
                      courseName: '5코스 숭례문구간',
                      polylineJsonFile: 'sungnyemun_path.json', // ✅ 여기를 JSON 파일명으로 변경
                      stampPoints: sungnyemunStampPoints, // ✅ stamp_points.dart에서 불러온 리스트
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
