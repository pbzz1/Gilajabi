import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../login.dart';
import 'package:gilajabi/board/liked_posts_page.dart';
import 'package:gilajabi/board/my_posts_page.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String? profileImageUrl;
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
      userId = user.id.toString();
      profileImageUrl = user.kakaoAccount?.profile?.profileImageUrl;

      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      setState(() {
        nickname = doc.data()?['nickname'] ?? '사용자';
      });
    } catch (e) {
      print('사용자 정보 가져오기 실패: $e');
    }
  }

  void _showNicknameEditDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController(text: nickname);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('닉네임 변경'),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: '새 닉네임 입력'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final newNickname = _controller.text.trim();
              if (newNickname.isNotEmpty && userId != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({'nickname': newNickname});

                setState(() {
                  nickname = newNickname;
                });
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('닉네임이 "$newNickname"(으)로 변경됨')),
              );
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _onMyPostsPressed() {
  if (userId == null) return;
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => MyPostsPage(userId: userId!)),
  );
}

  void _onLikedPostsPressed() {
  if (userId == null) return;
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => LikedPostsPage(userId: userId!)),
  );
}

  void _logout() async {
    try {
      await UserApi.instance.logout();
      print('로그아웃 성공');
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (error) {
      print('로그아웃 실패: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 프로필')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  child: profileImageUrl == null ? const Icon(Icons.person, size: 50) : null,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(nickname ?? '사용자', style: const TextStyle(fontSize: 18)),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showNicknameEditDialog(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 40),

          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('내가 쓴 글'),
            onTap: _onMyPostsPressed,
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('좋아요한 글'),
            onTap: _onLikedPostsPressed,
          ),

          const Divider(height: 40),

          Center(
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('로그아웃'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
