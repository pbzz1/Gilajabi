import 'package:flutter/material.dart';

class InwangsanInfoPage extends StatelessWidget {
  const InwangsanInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("6코스 인왕산구간")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "인왕산구간 설명",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}