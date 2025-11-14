import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LessonsScreen extends StatefulWidget {
  final int courseId;

  const LessonsScreen({Key? key, required this.courseId}) : super(key: key);

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
        .select('courses_id, title, description')
        .eq('courses_id', widget.courseId);

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
      appBar: AppBar(
        title: Text('Уроки курса'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _lessons.isEmpty
                  ? Center(child: Text('Уроки не найдены'))
                  : ListView.builder(
                      itemCount: _lessons.length,
                      itemBuilder: (context, index) {
                        final lesson = _lessons[index];
                        return Card(
                          margin:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(lesson.title),
                            subtitle: Text(
                              lesson.content,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              // Можно перейти в подробный просмотр урока
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
    return Lesson(
      id: json['id'] as int,
      coursesId: json['courses_id'] as int,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
    );
  }
}
