import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';

class LearningTab extends StatefulWidget {
  const LearningTab({super.key});

  @override
  State<LearningTab> createState() => _LearningTabState();
}

class _LearningTabState extends State<LearningTab> {
  List<Course> courses = [];
  bool isLoading = true;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    try {
      final data = await supabase.from('courses').select() as List<dynamic>;
      setState(() {
        courses = data.map((e) => Course(
          title: e['title'] ?? '',
          description: e['description'] ?? '',
          progress: (e['progress'] as num?)?.toDouble() ?? 0.0, // progress должен быть числом от 0 до 1
        )).toList();
        isLoading = false;
      });
    } catch (error) {
      print('Ошибка при загрузке курсов: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Обучение'),
        backgroundColor: AppColors.secondary,
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
                              value: course.progress, // Значение от 0.0 до 1.0
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
