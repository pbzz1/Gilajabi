import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'myhomepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true); // 반복 + 반대로 (줌 인 ➔ 줌 아웃)

    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> signInWithKakao(BuildContext context) async {
    try {
      if (await isKakaoTalkInstalled()) {
        try {
          await UserApi.instance.loginWithKakaoTalk();
          print('카카오톡으로 로그인 성공');
        } catch (error) {
          print('카카오톡 로그인 실패: $error');
          if (error is PlatformException && error.code == 'CANCELED') return;
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
        }
      } else {
        await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
      }

      final user = await UserApi.instance.me();
      final userId = user.id.toString();
      final kakaoNickname = user.kakaoAccount?.profile?.nickname;
      final profileImageUrl = user.kakaoAccount?.profile?.profileImageUrl;

      final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
      final userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        await userDocRef.set({
          'nickname': kakaoNickname,
          'profileImageUrl': profileImageUrl,
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else {
        await userDocRef.update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      }
    } catch (error) {
      print('카카오 로그인 실패: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지 (줌 인/아웃 애니메이션 적용)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: _animation.value,
                child: child,
              );
            },
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
            ),
          ),

          // 어두운 반투명 레이어
          Container(
            color: Colors.black.withOpacity(0.3),
          ),

          // 내용물
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/app_logo.png', height: 120),
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      Text(
                        '길라잡이에 오신 것을 환영합니다!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 2
                            ..color = Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        '길라잡이에 오신 것을 환영합니다!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () => signInWithKakao(context),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                      elevation: 2,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFFFEE500),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/kakao_login_large_wide.png', height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
