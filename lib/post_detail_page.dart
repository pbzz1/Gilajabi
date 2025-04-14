import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class PostDetailPage extends StatefulWidget {
  final String title;
  final String content;
  final String authorNickname;
  final DateTime? createdAt;
  final String? postId;

  const PostDetailPage({
    super.key,
    required this.title,
    required this.content,
    required this.authorNickname,
    this.createdAt,
    this.postId,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  String? nickname;
  String? userId;
  final TextEditingController _commentController = TextEditingController();

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

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty || widget.postId == null || userId == null || nickname == null) return;

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .add({
      'authorId': userId,
      'authorNickname': nickname,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = widget.createdAt != null
        ? '${widget.createdAt!.year}-${widget.createdAt!.month.toString().padLeft(2, '0')}-${widget.createdAt!.day.toString().padLeft(2, '0')} '
          '${widget.createdAt!.hour}:${widget.createdAt!.minute.toString().padLeft(2, '0')}'
        : '날짜 없음';

    return Scaffold(
      appBar: AppBar(title: const Text('글 상세보기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('작성자: ${widget.authorNickname}'),
            Text('작성일: $formattedDate'),
            const Divider(height: 32),
            Text(widget.content, style: const TextStyle(fontSize: 18)),
            const Divider(height: 32),
            const Text('댓글', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: widget.postId == null
                  ? const Text('댓글을 불러올 수 없습니다.')
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .doc(widget.postId)
                          .collection('comments')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final comments = snapshot.data!.docs;
                        if (comments.isEmpty) return const Text('아직 댓글이 없습니다.');

                        return ListView.builder(
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index].data() as Map<String, dynamic>;
                            return ListTile(
                              title: Text(comment['content'] ?? ''),
                              subtitle: Text(comment['authorNickname'] ?? ''),
                            );
                          },
                        );
                      },
                    ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(labelText: '댓글 입력'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}