import 'package:flutter/material.dart';
import 'theme.dart';

class LearningTab extends StatelessWidget {
  const LearningTab({super.key});

  final List<Course> courses = const [
    Course(
      title: 'Python для начинающих',
      description: 'Основы Python, синтаксис, переменные.',
      progress: 0.4,
    ),
    Course(
      title: 'JavaScript',
      description: 'Изучение JS с нуля до продвинутого уровня.',
      progress: 0.7,
    ),
    Course(
      title: 'SQL и базы данных',
      description: 'Работа с базами данных, запросы SQL.',
      progress: 0.15,
    ),
    Course(
      title: 'C# с нуля',
      description: 'Базовые вещи',
      progress: 0,
    ),
    Course(
      title: 'C++ для чайников',
      description: 'Изучение C++ как первого языка',
      progress: 0.55,
    ),
    Course(
      title: 'Flutter как смысл жизни',
      description: 'Научимся делать такие-же крутые моб. приложения',
      progress: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Обучение'),
        backgroundColor: AppColors.secondary,
      ),
      body: ListView.builder(
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
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}

class Course {
  final String title;
  final String description;
  final double progress;

  const Course({
    required this.title,
    required this.description,
    required this.progress,
  });
}
