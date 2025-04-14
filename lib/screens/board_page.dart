import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  String? nickname;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = await UserApi.instance.me();
      setState(() {
        userId = user.id.toString();
        nickname = user.kakaoAccount?.profile?.nickname ?? '알 수 없음';
      });
    } catch (e) {
      print('사용자 정보 로딩 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게시판')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final isAuthor = data['authorId'] == userId;

              return ListTile(
                title: Text(data['title'] ?? '제목 없음'),
                subtitle: Text(data['content'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(data['authorNickname'] ?? ''),
                    if (isAuthor) ...[
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showEditDialog(context, doc.id, data),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () => _deletePost(doc.id),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showWriteDialog(context),
        child: const Icon(Icons.edit),
      ),
    );
  }

  void _showWriteDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('글 작성'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: '제목')),
            TextField(controller: contentController, decoration: const InputDecoration(labelText: '내용')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text;
              final content = contentController.text;

              if (title.isNotEmpty && content.isNotEmpty && userId != null && nickname != null) {
                await FirebaseFirestore.instance.collection('posts').add({
                  'title': title,
                  'content': content,
                  'authorId': userId,
                  'authorNickname': nickname,
                  'createdAt': FieldValue.serverTimestamp(),
                });
              }

              Navigator.pop(context);
            },
            child: const Text('등록'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, String docId, Map<String, dynamic> data) {
    final titleController = TextEditingController(text: data['title']);
    final contentController = TextEditingController(text: data['content']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('글 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: '제목')),
            TextField(controller: contentController, decoration: const InputDecoration(labelText: '내용')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () async {
              final newTitle = titleController.text;
              final newContent = contentController.text;

              if (newTitle.isNotEmpty && newContent.isNotEmpty) {
                await FirebaseFirestore.instance.collection('posts').doc(docId).update({
                  'title': newTitle,
                  'content': newContent,
                });
              }
              Navigator.pop(context);
            },
            child: const Text('수정'),
          ),
        ],
      ),
    );
  }

  void _deletePost(String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('이 글을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance.collection('posts').doc(docId).delete();
    }
  }
}