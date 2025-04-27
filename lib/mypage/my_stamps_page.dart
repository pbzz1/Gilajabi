import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class MyStampsPage extends StatefulWidget {
  const MyStampsPage({super.key});

  @override
  State<MyStampsPage> createState() => _MyStampsPageState();
}

class _MyStampsPageState extends State<MyStampsPage> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    try {
      final user = await UserApi.instance.me();
      setState(() {
        userId = user.id.toString();
      });
    } catch (e) {
      print('userId 로드 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('로그인이 필요합니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 스탬프 목록'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('stamps')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final stamps = snapshot.data!.docs;

          if (stamps.isEmpty) {
            return const Center(child: Text('아직 찍은 스탬프가 없습니다.'));
          }

          return ListView.builder(
            itemCount: stamps.length,
            itemBuilder: (context, index) {
              final data = stamps[index].data() as Map<String, dynamic>;

              return ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(data['name'] ?? '스탬프'),
                subtitle: Text('코스: ${data['course'] ?? ''}'),
                trailing: Text(
                  (data['timestamp'] as Timestamp?)?.toDate().toString().substring(0, 16) ?? '',
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
