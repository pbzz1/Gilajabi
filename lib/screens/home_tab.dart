import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gilajabi/screens/profile_tab.dart';
import '../course/course_page.dart';
import '../board/board_page.dart';
import '../screens/settings_page.dart';
import '../providers/app_settings_provider.dart';
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
  int _steps = 0;
  int _baseDeviceSteps = 0;
  int _latestDeviceSteps = 0;

  final List<String> _bannerImages = [
    'assets/images/homeBanner0.png',
    'assets/images/homeBanner1.png',
    'assets/images/homeBanner2.png',
    'assets/images/homeBanner3.png',
  ];

  @override
  void initState() {
    super.initState();
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

  Future<void> _syncTodaySteps() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // 자정 기준

    final savedDateStr = prefs.getString('lastStepResetDate');
    final savedDate = savedDateStr != null ? DateTime.tryParse(savedDateStr) : null;

    if (savedDate == null || savedDate.isBefore(today)) {
      _baseDeviceSteps = _latestDeviceSteps;
      await prefs.setInt('baseDeviceSteps', _baseDeviceSteps);
      await prefs.setString('lastStepResetDate', today.toIso8601String());
    } else {
      _baseDeviceSteps = prefs.getInt('baseDeviceSteps') ?? 0;
    }
  }

  void _startListening() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream?.listen((StepCount event) async {
      _latestDeviceSteps = event.steps;
      await _syncTodaySteps();
      setState(() {
        _steps = _latestDeviceSteps - _baseDeviceSteps;
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastDeviceSteps = _steps + _baseDeviceSteps;
    await prefs.setInt('baseDeviceSteps', lastDeviceSteps);
    await prefs.setString('lastStepResetDate', today.toIso8601String());

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
            Text(label, style: const TextStyle(fontSize: 14,color: Colors.black)),  
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final isKoreanMode = settings.isKoreanMode;

    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 16),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                buildMenuButton(Icons.map, isKoreanMode ? '코스 선택' : 'Course', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CoursePage()));
                }),
                buildMenuButton(Icons.post_add, isKoreanMode ? '게시물' : 'Board', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BoardPage()));
                }),
                buildMenuButton(Icons.person, isKoreanMode ? '프로필' : 'Profile', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileTab()));
                }),
                buildMenuButton(Icons.settings, isKoreanMode ? '설정' : 'Settings', onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                  
                  if (result == true) {
                    setState(() {}); // 🔥 설정 끝나고 홈 리빌드
                  }
                },),
                buildMenuButton(Icons.edit_note, isKoreanMode ? '메모장' : 'Memo', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoPage()));
                }),
                buildMenuButton(Icons.info, isKoreanMode ? '정보' : 'Info', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const InfoPage()));
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
