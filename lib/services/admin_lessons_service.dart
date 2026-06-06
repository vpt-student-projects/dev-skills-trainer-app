import 'package:vpt_learn/services/api_client.dart';

class AdminLessonsService {
  final ApiClient _api = ApiClient();

  /// Получить все уроки курса
  Future<List<Map<String, dynamic>>> fetchLessons(int courseId) async {
    final data = await _api.get('/lessons/alllessons?courseid=$courseId');
    final List list = data['lessons'] ?? [];
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Создать урок
  Future<void> createLesson({
    required int courseId,
    required String title,
    required String content,
    required int orderIndex,
  }) async {
    await _api.post('/lessons', {
      'courseId': courseId,
      'title': title,
      'content': content,
      'orderIndex': orderIndex,
    });
  }

  /// Обновить урок
  Future<void> updateLesson({
    required int lessonId,
    required String title,
    required String content,
    required int orderIndex,
  }) async {
    await _api.put('/lessons/$lessonId', {
      'title': title,
      'content': content,
      'orderIndex': orderIndex,
    });
  }

  /// Удалить урок
  Future<void> deleteLesson(int lessonId) async {
    await _api.delete('/lessons/$lessonId');
  }
}