import 'package:flutter/material.dart';
import 'screens/home_tab.dart';
import 'board/board_page.dart';
import 'screens/profile_tab.dart';

class MyHomePage extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  final Function(bool) onToggleKoreanMode;
  final bool isKoreanMode;

  const MyHomePage({
    super.key,
    required this.onToggleDarkMode,
    required this.isDarkMode,
    required this.onToggleKoreanMode,
    required this.isKoreanMode,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeTab(
        onToggleDarkMode: widget.onToggleDarkMode,
        isDarkMode: widget.isDarkMode,
        onToggleKoreanMode: widget.onToggleKoreanMode,  
        isKoreanMode: widget.isKoreanMode,
      ),
      BoardPage(isKoreanMode: widget.isKoreanMode),
      ProfileTab(isKoreanMode: widget.isKoreanMode),
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
        title: Text(widget.isKoreanMode ? '길라잡이' : 'Gilajabi'), // ✅ 한영 적용
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: widget.isKoreanMode ? '홈' : 'Home', // ✅ 한영 적용
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.post_add),
            label: widget.isKoreanMode ? '게시물' : 'Posts', // ✅ 한영 적용
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: widget.isKoreanMode ? '프로필' : 'Profile', // ✅ 한영 적용
          ),
        ],
      ),
    );
  }
}
