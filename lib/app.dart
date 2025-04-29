import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_settings_provider.dart'; // ✅ 추가
import 'login.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppSettingsProvider(), // ✅ AppSettingsProvider 생성
      child: Consumer<AppSettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: '길라잡이',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light, // ✅ 다크모드 적용
            home: const LoginPage(), // ✅ 처음에는 LoginPage로
          );
        },
      ),
    );
  }
}
