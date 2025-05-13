import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:gilajabi/course/info/baegak_info_page.dart';
import 'package:gilajabi/course/info/naksan_info_page.dart';
import 'package:gilajabi/course/info/heunginjimun_info_page.dart';
import 'package:gilajabi/course/info/namsan_info_page.dart';
import 'package:gilajabi/course/info/sungnyemun_info_page.dart';
import 'package:gilajabi/course/info/inwangsan_info_page.dart';
import 'package:gilajabi/providers/app_settings_provider.dart';

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
        'CourseChannel',
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
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _sendCurrentLocation(),
        ),
      )
      ..loadRequest(Uri.parse('https://pbzz1.github.io/Gilajabi/kakao_map.html'));
  }

  Future<void> _sendCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();
      final js = "window.setUserLocation(${position.latitude}, ${position.longitude});";
      _controller.runJavaScript(js);
    } catch (e) {
      print('❌ 위치 전송 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKoreanMode = Provider.of<AppSettingsProvider>(context).isKoreanMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(isKoreanMode ? '코스 선택' : 'Course'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
