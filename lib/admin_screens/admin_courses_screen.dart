// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:vpt_learn/services/admin_courses_service.dart';
import 'admin_lessons_screen.dart';
import '/theme.dart';

class AdminCoursesScreen extends StatefulWidget {
  const AdminCoursesScreen({super.key});

  @override
  State<AdminCoursesScreen> createState() => _AdminCoursesScreenState();
}

class _AdminCoursesScreenState extends State<AdminCoursesScreen> {
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;
  final AdminCoursesService _service = AdminCoursesService();

  final List<String> _languages = ['python', 'c#'];
  final List<String> _levels = ['начальный', 'продвинутый'];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    try {
      _courses = await _service.fetchAllCourses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _createCourse() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedLanguage = _languages[0];
    String selectedLevel = _levels[0];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Новый курс'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Название'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Описание'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedLanguage,
                    decoration: const InputDecoration(labelText: 'Язык'),
                    items: _languages.map((lang) {
                      return DropdownMenuItem(value: lang, child: Text(lang));
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedLanguage = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedLevel,
                    decoration: const InputDecoration(labelText: 'Уровень'),
                    items: _levels.map((level) {
                      return DropdownMenuItem(value: level, child: Text(level));
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedLevel = value!;
                      });
                    },
                  ),
                ],
              ),
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
          );
        },
      ),
    );

    if (result != true) return;

    try {
      await _service.createCourse(
        title: titleController.text,
        description: descController.text,
        language: selectedLanguage,
        level: selectedLevel,
      );
      await _loadCourses();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Курс создан')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  Future<void> _editCourse(Map<String, dynamic> course) async {
    final titleController = TextEditingController(text: course['title']);
    final descController = TextEditingController(text: course['description'] ?? '');
    String selectedLanguage = course['language'] ?? _languages[0];
    String selectedLevel = course['level'] ?? _levels[0];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Редактировать курс'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Название'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Описание'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedLanguage,
                    decoration: const InputDecoration(labelText: 'Язык'),
                    items: _languages.map((lang) {
                      return DropdownMenuItem(value: lang, child: Text(lang));
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedLanguage = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedLevel,
                    decoration: const InputDecoration(labelText: 'Уровень'),
                    items: _levels.map((level) {
                      return DropdownMenuItem(value: level, child: Text(level));
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedLevel = value!;
                      });
                    },
                  ),
                ],
              ),
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
          );
        },
      ),
    );

    if (result != true) return;

    try {
      await _service.updateCourse(
        course['courseId'],
        title: titleController.text,
        description: descController.text,
        language: selectedLanguage,
        level: selectedLevel,
      );
      await _loadCourses();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Курс обновлён')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  Future<void> _deleteCourse(Map<String, dynamic> course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить курс?'),
        content: Text('Вы уверены, что хотите удалить "${course['title']}"?'),
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
      await _service.deleteCourse(course['courseId']);
      await _loadCourses();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Курс удалён')),
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
        title: const Text('Управление курсами'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createCourse,
            tooltip: 'Добавить курс',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCourses,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
              ? const Center(child: Text('Курсы не найдены'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _courses.length,
                  itemBuilder: (context, index) {
                    final course = _courses[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: ListTile(
                        title: Text(course['title']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (course['description'] != null)
                              Text(course['description'], maxLines: 1),
                            Text(
                              '${course['language'] ?? '?'} | ${course['level'] ?? '?'}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') _editCourse(course);
                            if (value == 'delete') _deleteCourse(course);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Редактировать')),
                            const PopupMenuItem(value: 'delete', child: Text('Удалить', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminLessonsScreen(
                                courseId: course['courseId'],
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