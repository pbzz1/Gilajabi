import 'package:flutter/material.dart';

class HeunginjimunInfoPage extends StatelessWidget {
  const HeunginjimunInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("3코스 흥인지문구간")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "흥인지문구간 설명",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}