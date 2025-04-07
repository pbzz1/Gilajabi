import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'nearby_facilities_page.dart';
import 'board_page.dart';
import 'settings_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? nickname;
  String? profileImageUrl;
  int _selectedIndex = 2; // 마이페이지를 기본 탭으로 가정

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = await UserApi.instance.me();
      setState(() {
        nickname = user.kakaoAccount?.profile?.nickname ?? '사용자';
        profileImageUrl = user.kakaoAccount?.profile?.profileImageUrl;
      });
    } catch (e) {
      print('사용자 정보 불러오기 실패: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 페이지들 리스트
  List<Widget> get _pages => [
    const NearbyFacilitiesPage(),
    const BoardPage(),
    _buildMyPage(),
    const SettingsPage(),
  ];

  // 마이페이지 위젯은 기존 구조 재사용
  Widget _buildMyPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (profileImageUrl != null)
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(profileImageUrl!),
            ),
          const SizedBox(height: 16),
          Text(
            nickname ?? '닉네임 불러오는 중...',
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('모바일 캡스톤디자인'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.place),
            label: '주변 시설',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: '게시판',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
