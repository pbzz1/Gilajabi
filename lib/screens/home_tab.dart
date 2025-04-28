import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gilajabi/screens/profile_tab.dart';
import '../course/course_page.dart';
import '../board/board_page.dart';
import 'package:pedometer/pedometer.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;
  
  // 만보기 관련 변수
  Stream<StepCount>? _stepCountStream;
  int _steps = 0;

  final List<String> _bannerImages = [
    'assets/images/homeBanner0.png',
    'assets/images/homeBanner1.png',
    'assets/images/homeBanner2.png',
    'assets/images/homeBanner3.png',
  ];

  @override
  void initState() {
    super.initState();
    // 배너 슬라이드 타이머
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _currentPage = (_currentPage + 1) % _bannerImages.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
    // 만보기 시작
    _startListening();
  }

  void _startListening() {
  _stepCountStream = Pedometer.stepCountStream;
  _stepCountStream?.listen((StepCount event) {
    print('걸음 수 이벤트: ${event.steps}'); // ← 이거 추가
    setState(() {
      _steps = event.steps;
    });
  }).onError((error) {
    print('만보기 오류: $error');
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
      body: ListView(
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

          // 🎯 메뉴 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                buildMenuButton(Icons.map, '코스 선택', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CoursePage()));
                }),
                buildMenuButton(Icons.post_add, '게시물', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BoardPage()));
                }),
                buildMenuButton(Icons.person, '프로필', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileTab()));
                }),
                buildMenuButton(Icons.settings, '설정'),
                buildMenuButton(Icons.notifications, '알림'),
                buildMenuButton(Icons.info, '정보'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🏃 걸음 수 카드
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_walk, size: 30, color: Colors.blueAccent),
                  const SizedBox(width: 12),
                  Text('걸음 수: $_steps', style: const TextStyle(fontSize: 20)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}