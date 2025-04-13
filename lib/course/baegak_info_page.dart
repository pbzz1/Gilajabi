import 'package:flutter/material.dart';

class BaegakInfoPage extends StatelessWidget {
  const BaegakInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("1코스 백악구간")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "백악구간 설명",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}