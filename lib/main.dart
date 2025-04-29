import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  KakaoSdk.init(
    nativeAppKey: '8b3cd8ee84d00cc92cd9a8940f9aa837',
    javaScriptAppKey: '8d8465643b5de1002ccbe7b3197fd029',
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false; 
  bool _isKoreanMode = true; // ✅ 한영모드 추가

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    bool? savedDarkMode = prefs.getBool('isDarkMode');
    bool? savedKoreanMode = prefs.getBool('isKoreanMode');

    setState(() {
      _isDarkMode = savedDarkMode ?? false;
      _isKoreanMode = savedKoreanMode ?? true; // ✅ 기본 한글모드
    });
  }

  void _toggleDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    setState(() {
      _isDarkMode = isDark;
    });
  }

  void _toggleKoreanMode(bool isKorean) async {  // ✅ 한영모드 토글
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isKoreanMode', isKorean);
    setState(() {
      _isKoreanMode = isKorean;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: LoginPage(
        onToggleDarkMode: _toggleDarkMode,
        isDarkMode: _isDarkMode,
        onToggleKoreanMode: _toggleKoreanMode, // ✅ 넘겨줌
        isKoreanMode: _isKoreanMode,
      ),
    );
  }
}
