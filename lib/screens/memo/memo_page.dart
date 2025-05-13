import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

import 'package:gilajabi/providers/app_settings_provider.dart';
import 'package:gilajabi/screens/memo/memo_edit_page.dart';

class Memo {
  String title;
  String content;
  DateTime createdAt;

  Memo({required this.title, required this.content, required this.createdAt});

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
      };

  static Memo fromJson(Map<String, dynamic> json) => Memo(
        title: json['title'],
        content: json['content'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}

class MemoPage extends StatefulWidget {
  const MemoPage({super.key});

  @override
  State<MemoPage> createState() => _MemoPageState();
}

class _MemoPageState extends State<MemoPage> {
  List<Memo> _memos = [];

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? memosString = prefs.getString('memos');
    if (memosString != null) {
      final List<dynamic> memoList = jsonDecode(memosString);
      setState(() {
        _memos = memoList.map((e) => Memo.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveMemos() async {
    final prefs = await SharedPreferences.getInstance();
    final String memosString = jsonEncode(_memos.map((e) => e.toJson()).toList());
    await prefs.setString('memos', memosString);
  }

  void _navigateToEdit({Memo? memo, int? index}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MemoEditPage(memo: memo),
      ),
    );

    if (result != null && result is Memo) {
      setState(() {
        if (index != null) {
          _memos[index] = result;
        } else {
          _memos.add(result);
        }
      });
      _saveMemos();
    } else if (result == 'delete' && index != null) {
      _deleteMemo(index);
    }
  }

  void _showDeleteMenu(int index) {
    final isKoreanMode = Provider.of<AppSettingsProvider>(context, listen: false).isKoreanMode;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: Text(isKoreanMode ? '삭제' : 'Delete'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int index) {
    final isKoreanMode = Provider.of<AppSettingsProvider>(context, listen: false).isKoreanMode;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isKoreanMode ? '메모 삭제' : 'Delete Memo'),
        content: Text(isKoreanMode ? '정말 이 메모를 삭제하시겠습니까?' : 'Are you sure you want to delete this memo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isKoreanMode ? '취소' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMemo(index);
            },
            child: Text(isKoreanMode ? '삭제' : 'Delete', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteMemo(int index) {
    setState(() {
      _memos.removeAt(index);
    });
    _saveMemos();
  }

  @override
  Widget build(BuildContext context) {
    final isKoreanMode = Provider.of<AppSettingsProvider>(context).isKoreanMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(isKoreanMode ? '메모장' : 'Memo Pad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: _memos.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3 / 2,
          ),
          itemBuilder: (context, index) {
            final memo = _memos[index];
            return GestureDetector(
              onTap: () => _navigateToEdit(memo: memo, index: index),
              onLongPress: () => _showDeleteMenu(index),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memo.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(
                          memo.content,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${memo.createdAt.year}.${memo.createdAt.month}.${memo.createdAt.day}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEdit(),
        child: const Icon(Icons.add),
        tooltip: isKoreanMode ? '새 메모 추가' : 'Add new memo',
      ),
    );
  }
}
