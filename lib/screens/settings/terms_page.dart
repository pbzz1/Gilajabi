import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('이용약관')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''[이용약관]

1. 목적
본 약관은 길라잡이 앱(이하 "본 앱")의 이용과 관련하여 이용자와 본 앱 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.

2. 이용자의 의무
- 본인의 정보는 정확하게 입력해야 하며, 타인의 정보를 도용해서는 안 됩니다.
- 서비스를 통해 불법적인 활동을 해서는 안 됩니다.

3. 서비스 제공
- 본 앱은 예고 없이 서비스의 내용을 변경하거나 중단할 수 있으며, 이에 대한 책임을 지지 않습니다.

4. 개인정보 보호
- 사용자의 개인정보는 관련 법령에 따라 안전하게 보호됩니다.

5. 면책조항
- 본 앱은 무료로 제공되며, 사용 중 발생한 문제에 대해 책임을 지지 않습니다.

본 약관은 최초 사용 시 동의한 것으로 간주되며, 변경사항은 공지 후 적용됩니다.
''',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
}
