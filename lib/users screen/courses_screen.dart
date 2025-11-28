import 'package:flutter/material.dart';
import '../theme.dart';
import 'lessons_screen.dart';

class LearningTab extends StatefulWidget {
  const LearningTab({super.key});

  @override
  State<LearningTab> createState() => _LearningTabState();
}

class _LearningTabState extends State<LearningTab> {
  List<Course> courses = const [
    Course(
      id: 1,
      title: 'Основы Flutter',
      description: 'Изучите базовые виджеты и структуру приложения.',
      progress: 0.3,
    ),
    Course(
      id: 2,
      title: 'Продвинутый Dart',
      description: 'Глубокое погружение в язык Dart и его фичи.',
      progress: 0.6,
    ),
    Course(
      id: 3,
      title: 'Работа с БД',
      description: 'Основы работы с локальными и удалёнными БД.',
      progress: 0.0,
    ),
  ];

  bool isLoading = false;

  void _openLessonsScreen(int courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonsScreen(courseId: courseId),
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Обучение'),
        backgroundColor: AppColors.secondary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : courses.isEmpty
              ? const Center(child: Text('Курсы не найдены'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          course.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(course.description),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: course.progress,
                              backgroundColor: Colors.grey[300],
                              color: AppColors.completed,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(course.progress * 100).toInt()}% завершено',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.completed,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _openLessonsScreen(course.id),
                      ),
                    );
                  },
                ),
    );
  }
}

class Course {
  final int id;
  final String title;
  final String description;
  final double progress;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
  });
}
