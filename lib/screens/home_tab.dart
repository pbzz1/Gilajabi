import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gilajabi/screens/profile_tab.dart';
import '../course/course_page.dart';
import '../board/board_page.dart';
import '../screens/settings_page.dart';

class HomeTab extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  final Function(bool) onToggleKoreanMode;
  final bool isKoreanMode;

  const HomeTab({
    super.key,
    required this.onToggleDarkMode,
    required this.isDarkMode,
    required this.onToggleKoreanMode,
    required this.isKoreanMode,
  });

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
                  widget.isKoreanMode ? '코스 선택' : 'Course',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CoursePage()),
                    );
                  },
                ),
                buildMenuButton(
                  Icons.post_add,
                  widget.isKoreanMode ? '게시물' : 'Board',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BoardPage(isKoreanMode: widget.isKoreanMode)),
                    );
                  },
                ),
                buildMenuButton(
                  Icons.person,
                  widget.isKoreanMode ? '프로필' : 'Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProfileTab(isKoreanMode: widget.isKoreanMode)),
                    );
                  },
                ),
                buildMenuButton(
                  Icons.settings,
                  widget.isKoreanMode ? '설정' : 'Settings',
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SettingsPage(
                          onToggleDarkMode: widget.onToggleDarkMode,
                          isDarkMode: widget.isDarkMode,
                          onToggleKoreanMode: widget.onToggleKoreanMode,
                          isKoreanMode: widget.isKoreanMode,
                        ),
                      ),
                    );
                    if (result == true) {
                      setState(() {}); // 🔥 설정 끝나고 홈 리빌드
                    }
                  },
                ),
                buildMenuButton(
                  Icons.notifications,
                  widget.isKoreanMode ? '알림' : 'Notification',
                ),
                buildMenuButton(
                  Icons.info,
                  widget.isKoreanMode ? '정보' : 'Info',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
