import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gilajabi/course/course_page.dart';
import 'package:gilajabi/screens/memo/memo_page.dart';
import 'package:gilajabi/screens/settings/settings_page.dart';
import 'package:gilajabi/providers/app_settings_provider.dart';

class MenuButtons extends StatelessWidget {
  const MenuButtons({super.key});

  Widget buildMenuButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 90,
      height: 90,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        border: Border.all(color: Colors.black.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final isKoreanMode = settings.isKoreanMode;

    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        buildMenuButton(
          context,
          Icons.map,
          isKoreanMode ? '코스 선택' : 'Course',
              () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CoursePage()));
          },
        ),
        buildMenuButton(
          context,
          Icons.edit_note,
          isKoreanMode ? '메모장' : 'Memo',
              () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoPage()));
          },
        ),
        buildMenuButton(
          context,
          Icons.settings,
          isKoreanMode ? '설정' : 'Settings',
              () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            );
            if (result == true) {
              // 설정 변경 후 처리
            }
          },
        ),
      ],
    );
  }
}
