import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'login.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? nickname;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // 🔹 사용자 정보 불러오기
  Future<void> _loadUserInfo() async {
    try {
      final user = await UserApi.instance.me();
      setState(() {
        nickname = user.kakaoAccount?.profile?.nickname ?? '사용자';
        profileImageUrl = user.kakaoAccount?.profile?.profileImageUrl;
      });
    } catch (e) {
      print('사용자 정보 불러오기 실패: $e');
    }
  }

  // 🔹 로그아웃 함수
  Future<void> logout(BuildContext context) async {
    try {
      await UserApi.instance.logout(); // 카카오 로그아웃
      print('로그아웃 성공');

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
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (profileImageUrl != null)
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(profileImageUrl!),
              ),
            const SizedBox(height: 16),
            Text(
              nickname ?? '닉네임 불러오는 중...',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
