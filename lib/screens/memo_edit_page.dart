import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ 추가
import '../providers/app_settings_provider.dart'; // ✅ 추가
import 'memo_page.dart';

class MemoEditPage extends StatefulWidget {
  final Memo? memo;

  const MemoEditPage({super.key, this.memo});

  @override
  State<MemoEditPage> createState() => _MemoEditPageState();
}

class _MemoEditPageState extends State<MemoEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.memo?.title ?? '');
    _contentController = TextEditingController(text: widget.memo?.content ?? '');
  }

  void _save() {
    final isKoreanMode = Provider.of<AppSettingsProvider>(context, listen: false).isKoreanMode;
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isKoreanMode ? '제목이나 내용을 입력하세요.' : 'Please enter title or content.')),
      );
      return;
    }

    final newMemo = Memo(
      title: title,
      content: content,
      createdAt: widget.memo?.createdAt ?? DateTime.now(),
    );

    Navigator.pop(context, newMemo);
  }

  void _confirmDelete() {
    final isKoreanMode = Provider.of<AppSettingsProvider>(context, listen: false).isKoreanMode;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isKoreanMode ? '메모 삭제' : 'Delete Memo'),
        content: Text(isKoreanMode ? '이 메모를 삭제하시겠습니까?' : 'Do you want to delete this memo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isKoreanMode ? '취소' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context, 'delete'); // 삭제 요청으로 돌아감
            },
            child: Text(isKoreanMode ? '삭제' : 'Delete', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKoreanMode = Provider.of<AppSettingsProvider>(context).isKoreanMode;
    final isEditing = widget.memo != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing
            ? (isKoreanMode ? '메모 수정' : 'Edit Memo')
            : (isKoreanMode ? '새 메모' : 'New Memo')),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
              tooltip: isKoreanMode ? '삭제' : 'Delete',
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
            tooltip: isKoreanMode ? '저장' : 'Save',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: isKoreanMode ? '제목을 입력하세요' : 'Enter title',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: isKoreanMode ? '메모를 입력하세요' : 'Enter memo content',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
