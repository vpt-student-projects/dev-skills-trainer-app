import 'package:vpt_learn/services/api_client.dart';

class AdminExercisesService {
  final ApiClient _api = ApiClient();

  /// Получить все задания урока
  Future<List<Map<String, dynamic>>> fetchExercises(int lessonId) async {
    final data = await _api.get('/lessons/alltasks?lessonId=$lessonId');
    final List list = data['exercises'] ?? [];
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Создать задание
  Future<void> createExercise({
    required int lessonId,
    required String taskDescription,
    required String rightAnswer,
    required List<String> answers,
  }) async {
    await _api.post('/lessons/tasks', {
      'lessonId': lessonId,
      'taskDescription': taskDescription,
      'rightAnswer': rightAnswer,
      'answers': answers.map((a) => {'answer': a}).toList(),
    });
  }

  /// Обновить задание
  Future<void> updateExercise({
    required int exerciseId,
    required String taskDescription,
    required String rightAnswer,
    required List<String> answers,
  }) async {
    await _api.put('/lessons/tasks/$exerciseId', {
      'taskDescription': taskDescription,
      'rightAnswer': rightAnswer,
      'answers': answers.map((a) => {'answer': a}).toList(),
    });
  }

  /// Удалить задание
  Future<void> deleteExercise(int exerciseId) async {
    await _api.delete('/lessons/tasks/$exerciseId');
  }
}