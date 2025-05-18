import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:gilajabi/screens/post/post_detail_page.dart';

class LikedPostsPage extends StatelessWidget {
  final String userId;
  const LikedPostsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('좋아요한 글')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('likes', arrayContains: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('좋아요한 글이 없습니다.'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final List<dynamic> images = data['imageUrls'] ?? [];
              return ListTile(
                title: Text(data['title'] ?? '제목 없음'),
                subtitle: Text(data['content'] ?? ''),
                trailing: Text(data['authorNickname'] ?? ''),
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
}