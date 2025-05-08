import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';
import 'onboarding_page.dart'; // ✅ 온보딩 페이지 추가
import 'providers/app_settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  await Firebase.initializeApp();

  KakaoSdk.init(
    nativeAppKey: '8b3cd8ee84d00cc92cd9a8940f9aa837',
    javaScriptAppKey: '8d8465643b5de1002ccbe7b3197fd029',
  );

  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  runApp(MyApp(isFirstLaunch: isFirstLaunch));
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
