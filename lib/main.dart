import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'app.dart'; // MyApp이 있는 파일

void main() {
  KakaoSdk.init(
    nativeAppKey: '3ebaf77a3cdfa4fa2a2e1d2388694936',
    javaScriptAppKey: 'd7e9c8ac8fea694b6444dc92bfdf6a1f',
  );
  runApp(const MyApp());
}