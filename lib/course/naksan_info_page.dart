import 'package:flutter/material.dart';

class NaksanInfoPage extends StatelessWidget {
  const NaksanInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("2코스 낙산구간")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "낙산구간 설명",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}