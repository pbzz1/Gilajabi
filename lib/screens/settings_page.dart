import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  final Function(bool) onToggleKoreanMode;
  final bool isKoreanMode;

  const SettingsPage({
    super.key,
    required this.onToggleDarkMode,
    required this.isDarkMode,
    required this.onToggleKoreanMode,
    required this.isKoreanMode,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool currentDarkMode;
  late bool currentKoreanMode;

  @override
  void initState() {
    super.initState();
    currentDarkMode = widget.isDarkMode;
    currentKoreanMode = widget.isKoreanMode;
  }

  @override
  void didUpdateWidget(covariant SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      currentDarkMode = widget.isDarkMode;
    }
    if (oldWidget.isKoreanMode != widget.isKoreanMode) {
      currentKoreanMode = widget.isKoreanMode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentKoreanMode ? '설정' : 'Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true); // ✅ 설정 변경 결과 넘기기
          },
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.language),
            title: const Text('한영 모드'),
            subtitle: Text(currentKoreanMode ? '한글 모드' : '영어 모드'),
            value: currentKoreanMode,
            onChanged: (bool value) {
              setState(() {
                currentKoreanMode = value;
              });
              widget.onToggleKoreanMode(value); // ✅ 상위(HomeTab)로 반영
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('다크 모드'),
            subtitle: Text(currentDarkMode ? '다크 모드' : '라이트 모드'),
            value: currentDarkMode,
            onChanged: (bool value) {
              setState(() {
                currentDarkMode = value;
              });
              widget.onToggleDarkMode(value);
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
