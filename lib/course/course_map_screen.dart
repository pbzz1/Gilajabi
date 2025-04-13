import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'baegak_info_page.dart';
import 'naksan_info_page.dart';
import 'heunginjimun_info_page.dart';
import 'namsan_info_page.dart';
import 'sungnyemun_info_page.dart';
import 'inwangsan_info_page.dart';

class CourseMapScreen extends StatelessWidget {
  const CourseMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'flutter_inappwebview',
        onMessageReceived: (msg) {
          final course = msg.message;
          switch (course) {
            case 'baegak':
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BaegakInfoPage()));
              break;
            case 'naksan':
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NaksanInfoPage()));
              break;
            case 'heunginjimun':
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HeunginjimunInfoPage()));
              break;
            case 'namsan':
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NamsanInfoPage()));
              break;
            case 'sungnyemun':
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SungnyemunInfoPage()));
              break;
            case 'inwangsan':
              Navigator.push(context, MaterialPageRoute(builder: (_) => const InwangsanInfoPage()));
              break;
          }
        },
      )
      ..loadFlutterAsset('assets/html/kakao_map.html');

    return Scaffold(
      appBar: AppBar(title: const Text("한양도성 코스 지도")),
      body: WebViewWidget(controller: controller),
    );
  }
}
