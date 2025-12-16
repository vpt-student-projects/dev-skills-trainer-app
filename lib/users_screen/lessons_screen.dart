// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:vpt_learn/models/lesson_model.dart';
import 'package:vpt_learn/services/lesson_service.dart';
import 'exercises_screen.dart';

class LessonsScreen extends StatefulWidget {
  final int courseId;

  const LessonsScreen({super.key, required this.courseId});

  @override
  _LessonsScreenState createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {

  String? _errorMessage;
  List<LessonModel> _lessons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    _lessons = await LessonService().fetchLessons(widget.courseId);
    setState(() => _isLoading = false);
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
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(lesson.title),
                            subtitle: Text(
                              lesson.content,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ExercisesScreen(lessonId: lesson.lessonId),
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
}
