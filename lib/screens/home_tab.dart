import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gilajabi/screens/profile_tab.dart';
import '../course/course_page.dart';
import '../board/board_page.dart';
import 'package:gilajabi/screens/info_page.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gilajabi/screens/memo_page.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  Stream<StepCount>? _stepCountStream;
  int _steps = 0; // 화면에 표시할 걸음 수
  int _baseDeviceSteps = 0; // 디바이스 누적 기준값

  final List<String> _bannerImages = [
    'assets/images/homeBanner0.png',
    'assets/images/homeBanner1.png',
    'assets/images/homeBanner2.png',
    'assets/images/homeBanner3.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadBaseDeviceSteps();
    _requestActivityPermission();
    _startListening();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _currentPage = (_currentPage + 1) % _bannerImages.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _requestActivityPermission() async {
    var status = await Permission.activityRecognition.status;
    if (!status.isGranted) {
      await Permission.activityRecognition.request();
    }
  }

  Future<void> _loadBaseDeviceSteps() async {
    final prefs = await SharedPreferences.getInstance();
    _baseDeviceSteps = prefs.getInt('baseDeviceSteps') ?? 0;
  }

  void _startListening() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream?.listen((StepCount event) {
      setState(() {
        _steps = event.steps - _baseDeviceSteps;
        if (_steps < 0) _steps = 0;
      });
    }).onError((error) {
      print('만보기 오류: $error');
    });
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('걸음 수 초기화'),
        content: const Text('걸음 수를 초기화하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              _resetSteps();
              Navigator.pop(context);
            },
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }

  void _resetSteps() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDeviceSteps = _steps + _baseDeviceSteps;
    await prefs.setInt('baseDeviceSteps', lastDeviceSteps);
    setState(() {
      _baseDeviceSteps = lastDeviceSteps;
      _steps = 0;
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
          // 배너
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

          // 메뉴 버튼
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
                buildMenuButton(Icons.edit_note, '메모장', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoPage()));
                }),
                buildMenuButton(Icons.info, '정보', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const InfoPage()));
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 걸음 수 카드
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.directions_walk, size: 30, color: Colors.blueAccent),
                      const SizedBox(width: 12),
                      Text('걸음 수: $_steps', style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _showResetConfirmationDialog,
                    icon: const Icon(Icons.refresh),
                    label: const Text('초기화'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    ),
                  ),
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