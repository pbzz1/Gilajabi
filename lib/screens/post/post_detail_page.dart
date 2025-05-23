import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:gilajabi/providers/app_settings_provider.dart';
import 'package:provider/provider.dart';

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
    final isKoreanMode = Provider.of<AppSettingsProvider>(context, listen: false).isKoreanMode;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isKoreanMode ? '댓글 수정' : 'Edit Comment'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: isKoreanMode ? '댓글' : 'Comment'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isKoreanMode ? '취소' : 'Cancel'),
          ),
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
            child: Text(isKoreanMode ? '수정' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _deleteComment(String docId) async {
    final isKoreanMode = Provider.of<AppSettingsProvider>(context, listen: false).isKoreanMode;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isKoreanMode ? '댓글 삭제' : 'Delete Comment'),
        content: Text(isKoreanMode ? '댓글을 삭제하시겠습니까?' : 'Do you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isKoreanMode ? '취소' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(isKoreanMode ? '삭제' : 'Delete'),
          ),
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
    final isKoreanMode = Provider.of<AppSettingsProvider>(context).isKoreanMode;

    return Scaffold(
      appBar: AppBar(title: Text(isKoreanMode ? '글 상세보기' : 'Post Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(isKoreanMode ? '작성자: ${widget.authorNickname}' : 'Author: ${widget.authorNickname}'),
            Text(isKoreanMode ? '작성일: $formattedDate' : 'Posted: $formattedDate'),
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

            if (widget.imageUrls != null && widget.imageUrls!.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: widget.imageUrls!.length,
                  controller: PageController(viewportFraction: 0.9),
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final imageUrl = widget.imageUrls![index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullscreenImagePage(imageUrl: imageUrl),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.contain, // 또는 BoxFit.fitWidth,
                            width: double.infinity,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(child: Icon(Icons.broken_image, size: 48));
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (widget.imageUrls!.length > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.imageUrls!.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      width: currentPage == index ? 12 : 8,
                      height: currentPage == index ? 12 : 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentPage == index ? Colors.blueAccent : Colors.grey,
                      ),
                    );
                  }),
                ),
            ],

            const SizedBox(height: 16),
            Text(widget.content, style: const TextStyle(fontSize: 18)),
            const Divider(height: 32),
            Text(isKoreanMode ? '댓글' : 'Comments',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: widget.postId == null
                  ? Text(isKoreanMode ? '댓글을 불러올 수 없습니다.' : 'Failed to load comments.')
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

                  if (comments.isEmpty) {
                    return Text(isKoreanMode ? '아직 댓글이 없습니다.' : 'No comments yet.');
                  }

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
                    decoration: InputDecoration(
                      labelText: isKoreanMode ? '댓글 입력' : 'Enter a comment',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ 전체화면 이미지 보기
class FullscreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullscreenImagePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.white));
            },
          ),
        ),
      ),
    );
  }
}
