import 'package:vpt_learn/models/exercise_model.dart';
import 'package:vpt_learn/models/lesson_model.dart';
import 'package:vpt_learn/services/api_client.dart';

class LessonService {
  final ApiClient _api = ApiClient();

  Future<List<LessonModel>> fetchLessons(int courseId) async {
    final data = await _api.get('/lessons/alllessons?courseid=$courseId');
    final List list = data['lessons'] ?? [];
    return list.map((e) => LessonModel.fromJson(e)).toList();
  }

  Future<List<ExerciseModel>> fetchExercises(int lessonId) async {
    final data = await _api.get('/lessons/alltasks?lessonId=$lessonId');
    final List list = data['exercises'] ?? [];
    return list.map((e) => ExerciseModel.fromJson(e)).toList();
  }

  /// Отправка результатов теста
  Future<Map<String, dynamic>> submitAnswers(int lessonId, List<Map<String, int>> answers) async {
    return await _api.post('/lessons/submit-test/$lessonId', {
      'answers': answers,
    });
  }
}