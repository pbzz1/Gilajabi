import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ 추가
import '../providers/app_settings_provider.dart'; // ✅ 추가

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key}); // ✅ 파라미터 모두 제거

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context); // ✅ Provider에서 상태 가져오기
    final isKoreanMode = settings.isKoreanMode;
    final isDarkMode = settings.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(isKoreanMode ? '설정' : 'Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true); // ✅ 설정 변경 결과 넘기기 (필요하면)
          },
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.language),
            title: const Text('한영 모드'),
            subtitle: Text(isKoreanMode ? '한글 모드' : '영어 모드'),
            value: isKoreanMode,
            onChanged: (bool value) {
              settings.toggleKoreanMode(value); // ✅ Provider 메서드 호출
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('다크 모드'),
            subtitle: Text(isDarkMode ? '다크 모드' : '라이트 모드'),
            value: isDarkMode,
            onChanged: (bool value) {
              settings.toggleDarkMode(value); // ✅ Provider 메서드 호출
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.verified),
            title: const Text('버전 정보'),
            subtitle: const Text('v1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text('이용약관'),
          ),
        ],
      ),
    );
  }
}
