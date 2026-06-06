import 'package:flutter/material.dart';
import 'package:vpt_learn/services/admin_lessons_service.dart';
import 'admin_exercises_screen.dart';
import '/theme.dart';

class AdminLessonsScreen extends StatefulWidget {
  final int courseId;
  const AdminLessonsScreen({super.key, required this.courseId});

  @override
  State<AdminLessonsScreen> createState() => _AdminLessonsScreenState();
}

class _AdminLessonsScreenState extends State<AdminLessonsScreen> {
  List<Map<String, dynamic>> _lessons = [];
  bool _isLoading = true;
  final AdminLessonsService _service = AdminLessonsService();

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    setState(() => _isLoading = true);
    try {
      _lessons = await _service.fetchLessons(widget.courseId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _createLesson() async {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final orderCtrl = TextEditingController(text: (_lessons.length + 1).toString());

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новый урок'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentCtrl,
              decoration: const InputDecoration(labelText: 'Содержание'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: orderCtrl,
              decoration: const InputDecoration(labelText: 'Порядок'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Создать'),
          ),
        ],
      ),
    );
    if (result != true) return;

    try {
      await _service.createLesson(
        courseId: widget.courseId,
        title: titleCtrl.text,
        content: contentCtrl.text,
        orderIndex: int.tryParse(orderCtrl.text) ?? _lessons.length + 1,
      );
      await _loadLessons();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Урок создан')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  Future<void> _editLesson(Map<String, dynamic> lesson) async {
    final titleCtrl = TextEditingController(text: lesson['title']);
    final contentCtrl = TextEditingController(text: lesson['content'] ?? '');
    final orderCtrl = TextEditingController(text: lesson['orderIndex'].toString());

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать урок'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentCtrl,
              decoration: const InputDecoration(labelText: 'Содержание'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: orderCtrl,
              decoration: const InputDecoration(labelText: 'Порядок'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    if (result != true) return;

    try {
      await _service.updateLesson(
        lessonId: lesson['lessonId'],
        title: titleCtrl.text,
        content: contentCtrl.text,
        orderIndex: int.tryParse(orderCtrl.text) ?? lesson['orderIndex'],
      );
      await _loadLessons();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Урок обновлён')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  Future<void> _deleteLesson(Map<String, dynamic> lesson) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить урок?'),
        content: Text('Вы уверены, что хотите удалить "${lesson['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _service.deleteLesson(lesson['lessonId']);
      await _loadLessons();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Урок удалён')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление уроками'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createLesson,
            tooltip: 'Добавить урок',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLessons,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lessons.isEmpty
              ? const Center(child: Text('Уроки не найдены'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = _lessons[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: ListTile(
                        title: Text(lesson['title']),
                        subtitle: lesson['content'] != null && lesson['content'].isNotEmpty
                            ? Text(lesson['content'], maxLines: 1, overflow: TextOverflow.ellipsis)
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editLesson(lesson),
                              tooltip: 'Редактировать',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteLesson(lesson),
                              tooltip: 'Удалить',
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminExercisesScreen(
                                lessonId: lesson['lessonId'],
                                lessonTitle: lesson['title'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}