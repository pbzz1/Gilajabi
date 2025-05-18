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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Padding(
       padding: const EdgeInsets.symmetric(vertical: 8.0), // 위아래 8픽셀 여백
          child: Image.asset(
            isDarkMode
                ? 'assets/images/Gilajabi_logo2.png'
                : 'assets/images/Gilajabi_logo.png',
            height: 55,
          ),
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react,
        backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : const Color(0xFFD6EDF9),
        activeColor: isDarkMode ? Colors.white : Colors.blueAccent,
        color: isDarkMode ? Colors.grey[400]! : Colors.grey,
        elevation: 6,                         // 그림자 깊이
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