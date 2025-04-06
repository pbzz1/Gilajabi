// lib/board_page.dart
import 'package:flutter/material.dart';

class BoardPage extends StatelessWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시판'),
      ),
      body: const Center(
        child: Text(
          '게시판 페이지',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
