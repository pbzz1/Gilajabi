import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'login.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  // 🔹 로그아웃 함수
  Future<void> logout(BuildContext context) async {
    try {
      await UserApi.instance.logout(); // 카카오 로그아웃
      print('로그아웃 성공');

      // 🔹 로그인 화면으로 이동 (현재 화면 제거)
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (error) {
      print('로그아웃 실패: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('모바일 캡스톤디자인'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // 로그아웃 아이콘
            onPressed: () => logout(context), // 로그아웃 실행
          ),
        ],
      ),
      body: const Center(
        child: Text('홈 화면'),
      ),
    );
  }
}
