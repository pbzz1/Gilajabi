import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'login.dart';
import 'myhomepage.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  bool _isDarkMode = false;
  bool _isKoreanMode = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final accessToken = await TokenManagerProvider.instance.manager.getToken();
    setState(() {
      _isLoggedIn = accessToken != null;
    });
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  void _toggleKoreanMode(bool value) {
    setState(() {
      _isKoreanMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '길라잡이',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _isLoggedIn
          ? MyHomePage(
              onToggleDarkMode: _toggleDarkMode,
              isDarkMode: _isDarkMode,
              onToggleKoreanMode: _toggleKoreanMode,
              isKoreanMode: _isKoreanMode,
            )
          : const LoginPage(),
    );
  }
}
