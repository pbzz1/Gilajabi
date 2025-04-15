import 'package:flutter/material.dart';

class NamsanInfoPage extends StatelessWidget {
  const NamsanInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("4코스 남산구간")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "남산구간 설명",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}