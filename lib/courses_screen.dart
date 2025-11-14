import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';
import 'lessons_screen.dart';

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
    setState(() {
      isLoading = true;
    });

    try {
      final data = await supabase.from('courses').select();
      setState(() {
        courses = (data as List<dynamic>).map((e) => Course(
          id: (e['courses_id'] != null) ? e['courses_id'] as int : 0,
          title: e['title'] ?? '',
          description: e['description'] ?? '',
          progress: (e['progress'] as num?)?.toDouble() ?? 0.0,
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

  void _openLessonsScreen(int courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonsScreen(courseId: courseId),
      ),
    );
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
