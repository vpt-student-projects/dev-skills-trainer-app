// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'exercises_screen.dart';

class LessonsScreen extends StatefulWidget {
  final int courseId;

  const LessonsScreen({super.key, required this.courseId});

  @override
  _LessonsScreenState createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  String? _errorMessage;
  List<Lesson> _lessons = [];

  @override
  void initState() {
    super.initState();
    _fetchLessons();
  }

  Future<void> _fetchLessons() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await supabase
          .from('lessons')
          .select('lesson_id, course_id, title, content')
          .eq('course_id', widget.courseId);

      setState(() {
        _lessons = (data as List<dynamic>)
            .map((json) => Lesson.fromJson(json as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка при загрузке уроков: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Уроки курса')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _lessons.isEmpty
                  ? const Center(child: Text('Уроки не найдены'))
                  : ListView.builder(
                      itemCount: _lessons.length,
                      itemBuilder: (context, index) {
                        final lesson = _lessons[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(lesson.title),
                            subtitle: Text(
                              lesson.content,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              // Переход на ExercisesScreen с передачей lesson.id
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ExercisesScreen(lessonId: lesson.id),
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

class Lesson {
  final int id;
  final int coursesId;
  final String title;
  final String content;

  Lesson({
    required this.id,
    required this.coursesId,
    required this.title,
    required this.content,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final id = json['lesson_id'];
    final courseId = json['course_id'];

    if (id == null || courseId == null) {
      throw Exception('lesson_id или course_id отсутствуют в данных урока: $json');
    }

    return Lesson(
      id: id as int,
      coursesId: courseId as int,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
    );
  }
}
