import 'package:flutter/material.dart';
import 'privacy_policy_page.dart'; // import 추가

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('앱 정보'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('길라잡이', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('버전: 1.0.0'),
            const SizedBox(height: 8),
            const Text('개발자: Team길라잡이'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()));
              },
              child: const Text('개인정보 처리방침'),
            ),
          ],
        ),
      ),
    );
  }
}