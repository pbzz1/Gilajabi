import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ 추가
import 'package:gilajabi/screens/profile_tab.dart';
import '../course/course_page.dart';
import '../board/board_page.dart';
import '../screens/settings_page.dart';
import '../providers/app_settings_provider.dart'; // ✅ 추가

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  final List<String> _bannerImages = [
    'assets/images/homeBanner0.png',
    'assets/images/homeBanner1.png',
    'assets/images/homeBanner2.png',
    'assets/images/homeBanner3.png',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _currentPage = (_currentPage + 1) % _bannerImages.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget buildMenuButton(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 90,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.black87),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context); // ✅ Provider로 상태 가져오기
    final isKoreanMode = settings.isKoreanMode;

    return Scaffold(
      body: Column(
        children: [
          // 🖼 배너
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _bannerImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    _bannerImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // 🎯 메뉴 버튼들
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                buildMenuButton(
                  Icons.map,
                  isKoreanMode ? '코스 선택' : 'Course',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CoursePage()),
                    );
                  },
                ),
                buildMenuButton(
                  Icons.post_add,
                  isKoreanMode ? '게시물' : 'Board',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BoardPage()),
                    );
                  },
                ),
                buildMenuButton(
                  Icons.person,
                  isKoreanMode ? '프로필' : 'Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileTab()),
                    );
                  },
                ),
                buildMenuButton(
                  Icons.settings,
                  isKoreanMode ? '설정' : 'Settings',
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsPage(), // ✅ 바로 const SettingsPage
                      ),
                    );
                    if (result == true) {
                      setState(() {}); // 🔥 설정 끝나고 홈 리빌드
                    }
                  },
                ),
                buildMenuButton(
                  Icons.notifications,
                  isKoreanMode ? '알림' : 'Notification',
                ),
                buildMenuButton(
                  Icons.info,
                  isKoreanMode ? '정보' : 'Info',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
