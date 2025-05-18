import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gilajabi/screens/settings/terms_page.dart';
import 'package:gilajabi/providers/app_settings_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final isKoreanMode = settings.isKoreanMode;
    final isDarkMode = settings.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(isKoreanMode ? '설정' : 'Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.language),
            title: Text(isKoreanMode ? '언어' : 'Language'),
            subtitle: Text(isKoreanMode ? '한글' : 'English'),
            value: !isKoreanMode,
            onChanged: (bool value) {
              settings.toggleKoreanMode(!value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: Text(isKoreanMode ? '다크 모드' : 'Dark Mode'),
            subtitle: Text(isDarkMode
                ? (isKoreanMode ? '화면 모드' : 'Dark Mode')
                : (isKoreanMode ? '라이트 모드' : 'Light Mode')),
            value: isDarkMode,
            onChanged: (bool value) {
              settings.toggleDarkMode(value);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.verified),
            title: Text(isKoreanMode ? '버전 정보' : 'Version Info'),
            subtitle: const Text('v1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.policy),
            title: Text(isKoreanMode ? '이용약관' : 'Terms of Use'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
