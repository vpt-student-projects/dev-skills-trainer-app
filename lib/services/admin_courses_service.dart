import 'package:vpt_learn/services/api_client.dart';

class AdminCoursesService {
  final ApiClient _api = ApiClient();

  Future<List<Map<String, dynamic>>> fetchAllCourses() async {
    final data = await _api.get('/courses/allcourses');
    return List<Map<String, dynamic>>.from(data['courses']);
  }

  Future<void> createCourse(String title, String description) async {
    await _api.post('/courses', {
      'title': title,
      'description': description,
    });
  }

  Future<void> updateCourse(int courseId, String title, String description) async {
    await _api.put('/courses/$courseId', {
      'title': title,
      'description': description,
    });
  }

  Future<void> deleteCourse(int courseId) async {
    await _api.delete('/courses/$courseId');
  }
}