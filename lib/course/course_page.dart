import 'package:flutter/material.dart';

class CoursePage extends StatelessWidget {
  const CoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('코스 선택'),
      ),
      body: const Center(
        child: Text(
          '여기서 코스를 선택하세요',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}