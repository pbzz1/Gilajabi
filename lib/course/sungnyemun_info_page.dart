import 'package:flutter/material.dart';

class SungnyemunInfoPage extends StatelessWidget {
  const SungnyemunInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("5코스 숭례문구간")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "숭례문구간 설명",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}