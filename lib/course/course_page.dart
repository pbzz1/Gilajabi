import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'baegak_info_page.dart';
import 'naksan_info_page.dart';
import 'heunginjimun_info_page.dart';
import 'namsan_info_page.dart';
import 'sungnyemun_info_page.dart';
import 'inwangsan_info_page.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'flutter_inappwebview',
        onMessageReceived: (message) {
          final course = message.message;
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
      ..loadRequest(Uri.parse('https://pbzz1.github.io/Gilajabi/kakao_map.html'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('코스 선택')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
