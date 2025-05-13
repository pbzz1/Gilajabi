import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gilajabi/screens/home/home_tab.dart';
import 'package:gilajabi/screens//post/post_page.dart';
import 'package:gilajabi/screens/profile/profile_tab.dart';
import 'package:gilajabi/providers/app_settings_provider.dart';

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
        title: Padding(
       padding: const EdgeInsets.symmetric(vertical: 8.0), // 위아래 8픽셀 여백
          child: Image.asset(
            'assets/images/Gilajabi_logo.png',
            height: 40,
          ),
        ),
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
