import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:gilajabi/screens/post/post_detail_page.dart';

class MyPostsPage extends StatelessWidget {
  final String userId;
  const MyPostsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내가 쓴 글')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('authorId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('작성한 글이 없습니다.'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final List<dynamic> images = data['imageUrls'] ?? [];
              return ListTile(
                title: Text(data['title'] ?? '제목 없음'),
                subtitle: Text(data['content'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditDialog(context, doc.id, data),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _deletePost(context, doc.id, List<String>.from(images)),
                    ),
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailPage(
                      postId: doc.id,
                      title: data['title'] ?? '',
                      content: data['content'] ?? '',
                      authorNickname: data['authorNickname'] ?? '',
                      createdAt: data['createdAt']?.toDate(),
                      imageUrls: List<String>.from(images),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _deletePost(BuildContext context, String docId, List<String> imageUrls) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('이 글과 이미지들을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
        ],
      ),
    );

    if (confirmed == true) {
      for (final url in imageUrls) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(url);
          await ref.delete();
        } catch (e) {
          debugPrint("이미지 삭제 실패: $e");
        }
      }
      await FirebaseFirestore.instance.collection('posts').doc(docId).delete();
    }
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
}