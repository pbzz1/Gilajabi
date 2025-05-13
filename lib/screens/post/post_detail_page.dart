import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class PostDetailPage extends StatefulWidget {
  final String title;
  final String content;
  final String authorNickname;
  final DateTime? createdAt;
  final String? postId;
  final List<String>? imageUrls;

  const PostDetailPage({
    super.key,
    required this.title,
    required this.content,
    required this.authorNickname,
    this.createdAt,
    this.postId,
    this.imageUrls,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  String? nickname;
  String? userId;
  List<dynamic> likes = [];
  final TextEditingController _commentController = TextEditingController();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadLikes();
  }

  Future<void> _loadUserInfo() async {
  try {
    final user = await UserApi.instance.me();
    userId = user.id.toString();

    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    setState(() {
      nickname = doc.data()?['nickname'] ?? '사용자';
    });
    } catch (e) {
      print('사용자 정보 로딩 실패: $e');
    }
  }

  Future<void> _loadLikes() async {
    if (widget.postId == null) return;
    final doc = await FirebaseFirestore.instance.collection('posts').doc(widget.postId).get();
    setState(() {
      likes = doc.data()?['likes'] ?? [];
    });
  }

  Future<void> _toggleLike() async {
    if (widget.postId == null || userId == null) return;
    final docRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
    final isLiked = likes.contains(userId);

    if (isLiked) {
      await docRef.update({'likes': FieldValue.arrayRemove([userId])});
    } else {
      await docRef.update({'likes': FieldValue.arrayUnion([userId])});
    }
    _loadLikes();
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

  void _editComment(String docId, String currentContent) {
    final controller = TextEditingController(text: currentContent);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('댓글 수정'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: '댓글'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () async {
              final newContent = controller.text.trim();
              if (newContent.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.postId)
                    .collection('comments')
                    .doc(docId)
                    .update({'content': newContent});
              }
              Navigator.pop(context);
            },
            child: const Text('수정'),
          ),
        ],
      ),
    );
  }

  void _deleteComment(String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('댓글 삭제'),
        content: const Text('댓글을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(docId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = widget.createdAt != null
        ? '${widget.createdAt!.year}-${widget.createdAt!.month.toString().padLeft(2, '0')}-${widget.createdAt!.day.toString().padLeft(2, '0')} '
            '${widget.createdAt!.hour}:${widget.createdAt!.minute.toString().padLeft(2, '0')}'
        : '날짜 없음';

    final isLiked = userId != null && likes.contains(userId);

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
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : null,
                  ),
                  onPressed: _toggleLike,
                ),
                Text('${likes.length}')
              ],
            ),
            const Divider(height: 32),
            if (widget.imageUrls != null && widget.imageUrls!.isNotEmpty)
              Column(
                children: [
                  SizedBox(
                    height: 250,
                    child: PageView.builder(
                      itemCount: widget.imageUrls!.length,
                      onPageChanged: (index) => setState(() => currentPage = index),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.imageUrls![index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.imageUrls!.length, (index) =>
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentPage == index ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
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
                            final doc = comments[index];
                            final comment = doc.data() as Map<String, dynamic>;
                            final isMine = comment['authorId'] == userId;
                            return ListTile(
                              title: Text(comment['content'] ?? ''),
                              subtitle: Text(comment['authorNickname'] ?? ''),
                              trailing: isMine
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 20),
                                          onPressed: () => _editComment(doc.id, comment['content']),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 20),
                                          onPressed: () => _deleteComment(doc.id),
                                        ),
                                      ],
                                    )
                                  : null,
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