import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gilajabi/screens/login.dart';
import 'package:gilajabi/screens/profile/my_liked_posts_page.dart';
import 'package:gilajabi/screens/profile/my_posts_page.dart';
import 'package:gilajabi/screens/profile/my_stamps_page.dart';
import 'package:gilajabi/providers/app_settings_provider.dart';

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
      final settings = Provider.of<AppSettingsProvider>(context, listen: false);
      final isKoreanMode = settings.isKoreanMode;

      setState(() {
        nickname = doc.data()?['nickname'] ?? (isKoreanMode ? '사용자' : 'User');
      });
    } catch (e) {
      print('사용자 정보 가져오기 실패: $e');
    }
  }

  void _showNicknameEditDialog(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context, listen: false);
    final isKoreanMode = settings.isKoreanMode;

    final TextEditingController _controller = TextEditingController(text: nickname);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isKoreanMode ? '닉네임 변경' : 'Change Nickname'),
        content: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: isKoreanMode ? '새 닉네임 입력' : 'Enter new nickname',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isKoreanMode ? '취소' : 'Cancel'),
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

                final allPosts = await FirebaseFirestore.instance.collection('posts').get();
                for (final postDoc in allPosts.docs) {
                  final postRef = postDoc.reference;
                  if (postDoc.data()['authorId'] == userId) {
                    await postRef.update({'authorNickname': newNickname});
                  }

                  final commentsSnapshot = await postRef.collection('comments').get();
                  for (final commentDoc in commentsSnapshot.docs) {
                    if (commentDoc.data()['authorId'] == userId) {
                      await commentDoc.reference.update({'authorNickname': newNickname});
                    }
                  }
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isKoreanMode
                      ? '닉네임이 \"$newNickname\"(으)로 변경되었습니다.'
                      : 'Nickname changed to \"$newNickname\"')),
                );
              }
              },
            child: Text(isKoreanMode ? '저장' : 'Save'),
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

  void _onMyStampsPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyStampsPage()),
    );
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId'); // 자동 로그인 해제
    await prefs.setBool('isFirstLaunch', false); // 필요시 초기화

    try {
      await UserApi.instance.logout();
      print('카카오 로그아웃 성공');
    } catch (error) {
      print('카카오 로그아웃 실패: $error');
    }

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final isKoreanMode = settings.isKoreanMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(isKoreanMode ? '프로필' : 'Profile'),
      ),
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
                    Text(nickname ?? (isKoreanMode ? '사용자' : 'User'), style: const TextStyle(fontSize: 18)),
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
            title: Text(isKoreanMode ? '내가 쓴 글' : 'My Posts'),
            onTap: _onMyPostsPressed,
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: Text(isKoreanMode ? '좋아요한 글' : 'Liked Posts'),
            onTap: _onLikedPostsPressed,
          ),
          ListTile(
            leading: const Icon(Icons.verified),
            title: Text( isKoreanMode ? '내 스탬프 보기' : 'My Stamps'),
            onTap: _onMyStampsPressed,
          ),
          const Divider(height: 40),
          Center(
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: Text(isKoreanMode ? '로그아웃' : 'Logout'),
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