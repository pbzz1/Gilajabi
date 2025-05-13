import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

import 'package:gilajabi/screens/home/home_tab.dart';
import 'package:gilajabi/screens//post/post_page.dart';
import 'package:gilajabi/screens/profile/profile_tab.dart';
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react, // 또는 fixed, flip, textIn, reactCircle 등
        backgroundColor: const Color(0xFFD6EDF9), // 하단 배경 (살짝 진한 파우더 블루)
        activeColor: Colors.blueAccent,           // 선택된 아이템 색상
        color: Colors.grey,                       // 비선택 아이템 색상
        elevation: 6,                             // 그림자 깊이
        initialActiveIndex: _selectedIndex,
        items: [
          TabItem(icon: Icons.home, title: ''),   // 라벨 숨김
          TabItem(icon: Icons.post_add, title: ''),
          TabItem(icon: Icons.person, title: ''),
        ],
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
