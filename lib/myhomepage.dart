import 'package:flutter/material.dart';
import 'package:gilajabi/screens/home_tab.dart';
import 'package:gilajabi/board/board_page.dart';
import 'package:gilajabi/screens/profile_tab.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart'; // ✅ 추가

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key}); // ✅ 넘겨받는 파라미터 제거

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      HomeTab(),
      BoardPage(),
      ProfileTab(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context); // ✅ Provider로 접근
    final isKoreanMode = settings.isKoreanMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(isKoreanMode ? '길라잡이' : 'Gilajabi'), // ✅ 한영 적용
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: isKoreanMode ? '홈' : 'Home', // ✅ 한영 적용
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.post_add),
            label: isKoreanMode ? '게시물' : 'Posts', // ✅ 한영 적용
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: isKoreanMode ? '프로필' : 'Profile', // ✅ 한영 적용
          ),
        ],
      ),
    );
  }
}
