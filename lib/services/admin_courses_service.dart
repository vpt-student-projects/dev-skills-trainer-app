import 'package:vpt_learn/services/api_client.dart';

class AdminCoursesService {
  final ApiClient _api = ApiClient();

  Future<List<Map<String, dynamic>>> fetchAllCourses() async {
    final data = await _api.get('/courses/allcourses');
    return List<Map<String, dynamic>>.from(data['courses']);
  }

  Future<void> createCourse({
    required String title,
    required String description,
    required String language,
    required String level,
  }) async {
    await _api.post('/courses', {
      'title': title,
      'description': description,
      'language': language,
      'level': level,
    });
  }

  Future<void> updateCourse(
    int courseId, {
    required String title,
    required String description,
    required String language,
    required String level,
  }) async {
    await _api.put('/courses/$courseId', {
      'title': title,
      'description': description,
      'language': language,
      'level': level,
    });
  }

  Future<void> deleteCourse(int courseId) async {
    await _api.delete('/courses/$courseId');
  }
}