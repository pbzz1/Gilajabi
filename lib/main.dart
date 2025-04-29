import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // ✅ 추가
import 'login.dart';
import 'providers/app_settings_provider.dart'; // ✅ 추가

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 플랫폼 뷰 등록 초기화 (Android용)
  await InAppWebViewController.setWebContentsDebuggingEnabled(true);

  await Firebase.initializeApp();

  KakaoSdk.init(
    nativeAppKey: '8b3cd8ee84d00cc92cd9a8940f9aa837',
    javaScriptAppKey: '8d8465643b5de1002ccbe7b3197fd029',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppSettingsProvider(), // ✅ Provider 생성
      child: Consumer<AppSettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light, // ✅ 다크모드 적용
            home: const LoginPage(), // ✅ 그냥 const LoginPage()
          );
        },
      ),
    );
  }
}
