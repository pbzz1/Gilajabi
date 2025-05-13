import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:gilajabi/providers/app_settings_provider.dart';
import 'package:gilajabi/screens/login.dart';
import 'package:gilajabi/screens/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // WebView 디버깅, Firebase 초기화, Kakao SDK 초기화
  await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  await Firebase.initializeApp();

  KakaoSdk.init(
    nativeAppKey: '8b3cd8ee84d00cc92cd9a8940f9aa837',
    javaScriptAppKey: '8d8465643b5de1002ccbe7b3197fd029',
  );

  // SharedPreferences에서 온보딩 여부 확인
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  runApp(MyApp(isFirstLaunch: isFirstLaunch));
  //runApp(const MyApp(isFirstLaunch: true)); // 💡 테스트용 강제 설정
}

class MyApp extends StatelessWidget {
  final bool isFirstLaunch;
  const MyApp({super.key, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppSettingsProvider(),
      child: Consumer<AppSettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: isFirstLaunch ? const OnboardingPage() : const LoginPage(),
          );
        },
      ),
    );
  }
}
