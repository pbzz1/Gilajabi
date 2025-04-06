// lib/my_page.dart
import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
      ),
      body: const Center(
        child: Text(
          '마이페이지',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
