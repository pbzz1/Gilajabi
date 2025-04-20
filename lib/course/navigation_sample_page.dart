import 'package:flutter/material.dart';

class NavigationSamplePage extends StatelessWidget {
  const NavigationSamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('코스 내비게이션 샘플')),
      body: const Center(
        child: Text(
          '여기에 지도와 경로 정보가 표시될 예정입니다.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
