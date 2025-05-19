import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';

import 'package:gilajabi/providers/app_settings_provider.dart';

class MyStampsPage extends StatefulWidget {
  const MyStampsPage({super.key});

  @override
  State<MyStampsPage> createState() => _MyStampsPageState();
}

class _MyStampsPageState extends State<MyStampsPage> with TickerProviderStateMixin {
  String? userId;
  Map<String, bool> expandedCourses = {};

  final Map<String, int> totalStampsPerCourse = {
    '1코스 백악구간': 3,
    '2코스 낙산구간': 3,
    '3코스 흥인지문구간': 3,
    '4코스 남산구간': 3,
    '5코스 숭례문구간': 3,
    '6코스 인왕산구간': 3,
  };

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
    final isKoreanMode = Provider.of<AppSettingsProvider>(context).isKoreanMode;
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

          final Map<String, List<QueryDocumentSnapshot>> courseGroups = {};
          for (var doc in stamps) {
            final data = doc.data() as Map<String, dynamic>;
            final course = data['course'] ?? '기타';
            courseGroups.putIfAbsent(course, () => []).add(doc);
          }

          return ListView(
            children: courseGroups.entries.map((entry) {
              final course = entry.key;
              final courseStamps = entry.value;
              final total = totalStampsPerCourse[course] ?? courseStamps.length;
              final percent = ((courseStamps.length / total) * 100).round();

              final isExpanded = expandedCourses[course] ?? true;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        expandedCourses[course] = !isExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: Colors.blueGrey[200],
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isExpanded ? Icons.expand_less : Icons.expand_more,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                course,
                                style: const TextStyle(fontSize: 18, color: Colors.black),
                              ),
                            ],
                          ),
                          Text('$percent% ${isKoreanMode ? '완료' : 'completed'}'),
                        ],
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) => SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1.0,
                      child: child,
                    ),
                    child: isExpanded
                        ? Column(
                      key: ValueKey(true),
                      children: courseStamps.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return ListTile(
                          leading: const Icon(Icons.verified),
                          title: Text(data['name'] ?? '스탬프'),
                          subtitle: Text(
                            (data['timestamp'] as Timestamp?)?.toDate().toString().substring(0, 16) ?? '',
                          ),
                        );
                      }).toList(),
                    )
                        : const SizedBox.shrink(key: ValueKey(false)),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
