import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('개인정보 처리방침'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('개인정보 처리방침', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('본 애플리케이션(이하 "앱")은 사용자 개인정보 보호를 최우선으로 생각합니다. '
                '본 개인정보 처리방침은 사용자가 본 앱을 이용할 때 수집되는 정보와 그 이용 방법을 설명합니다.\n'),

            Text('1. 수집하는 개인정보 항목', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('- 닉네임, 프로필 사진 (사용자가 작성한 정보)\n'
                 '- 게시글 및 댓글 내용\n'
                 '- 앱 사용 기록\n'
                 '- 걸음 수 데이터 (선택적)\n'),

            Text('2. 개인정보 수집 및 이용 목적', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('- 커뮤니티 기능 제공\n'
                 '- 개인화된 서비스 제공\n'
                 '- 코스 추천 및 트래킹 지원\n'
                 '- 걷기 활동 지원\n'
                 '- 앱 품질 개선 및 통계 분석\n'),

            Text('3. 개인정보 보유 및 이용 기간', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('- 앱 삭제 또는 개인정보 삭제 요청 시까지\n'
                 '- 일부 데이터는 서버(Firebase Firestore)에 저장될 수 있음\n'),

            Text('4. 개인정보 제3자 제공', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('- 개인정보를 외부에 제공하지 않음\n'),

            Text('5. 개인정보 보호 조치', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('- 데이터는 안전하게 저장 및 관리\n'
                 '- 걸음 수 데이터는 로컬 저장\n'),
          ],
        ),
      ),
    );
  }
}