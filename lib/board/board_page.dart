import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'post_detail_page.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  String? nickname;
  String? userId;
  List<String> uploadedImageUrls = [];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
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

  Future<List<String>> _pickAndUploadImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isEmpty) return [];

    List<String> urls = [];
    for (var pickedFile in pickedFiles) {
      final file = File(pickedFile.path);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('post_images/$fileName.jpg');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
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
              final List<dynamic> likes = data['likes'] ?? [];
              final List<dynamic> images = data['imageUrls'] ?? [];

              return ListTile(
                title: Row(
                  children: [
                    Expanded(child: Text(data['title'] ?? '제목 없음')),
                    if (images.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(left: 4.0),
                        child: Icon(Icons.image, size: 16, color: Colors.grey),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['content'] ?? ''),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 16, color: Colors.red),
                        const SizedBox(width: 4),
                        Text('${likes.length}')
                      ],
                    )
                  ],
                ),
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
                        onPressed: () => _deletePost(doc.id, List<String>.from(images)),
                      ),
                    ],
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailPage(
                        postId: doc.id,
                        title: data['title'] ?? '제목 없음',
                        content: data['content'] ?? '',
                        authorNickname: data['authorNickname'] ?? '',
                        createdAt: data['createdAt']?.toDate(),
                        imageUrls: List<String>.from(images),
                      ),
                    ),
                  );
                },
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

  void _deletePost(String docId, List<String> imageUrls) async {
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

  void _showWriteDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('글 작성'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: '제목')),
                TextField(controller: contentController, decoration: const InputDecoration(labelText: '내용')),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: isUploading
                      ? null
                      : () async {
                          setState(() {
                            isUploading = true;
                          });
                          final urls = await _pickAndUploadImages();
                          if (context.mounted) {
                            setState(() {
                              uploadedImageUrls = urls;
                              isUploading = false;
                            });
                          }
                        },
                  child: isUploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('이미지 업로드'),
                ),
                if (uploadedImageUrls.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: uploadedImageUrls
                        .map((url) => Image.network(url, height: 80, width: 80, fit: BoxFit.cover))
                        .toList(),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
            ElevatedButton(
              onPressed: isUploading
                  ? null
                  : () async {
                      final title = titleController.text;
                      final content = contentController.text;

                      if (title.isNotEmpty && content.isNotEmpty && userId != null && nickname != null) {
                        await FirebaseFirestore.instance.collection('posts').add({
                          'title': title,
                          'content': content,
                          'authorId': userId,
                          'authorNickname': nickname,
                          'likes': [],
                          'imageUrls': uploadedImageUrls,
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                      }

                      uploadedImageUrls = [];
                      Navigator.pop(context);
                    },
              child: const Text('등록'),
            ),
          ],
        ),
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
}