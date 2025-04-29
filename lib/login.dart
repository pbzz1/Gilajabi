import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'myhomepage.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key); // ✅ 생성자 파라미터 다 삭제!

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

      // 사용자 정보 가져오기
      final user = await UserApi.instance.me();
      final userId = user.id.toString();
      final nickname = user.kakaoAccount?.profile?.nickname;
      final profileImageUrl = user.kakaoAccount?.profile?.profileImageUrl;

      // Firestore 저장
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'nickname': nickname,
        'profileImageUrl': profileImageUrl,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 홈으로 이동
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MyHomePage(), // ✅ 여기 깔끔하게 수정
          ),
        );
      }
    } catch (error) {
      print('카카오 로그인 실패: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("로그인")),
      body: Center(
        child: InkWell(
          onTap: () => signInWithKakao(context),
          child: Card(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
            elevation: 2,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('images/kakao_login_large_wide.png', height: 30),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}