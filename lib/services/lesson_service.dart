import 'package:vpt_learn/models/lesson_model.dart';
import 'package:vpt_learn/services/api_client.dart';

class LessonService {
  final ApiClient _api = ApiClient();

  Future<List<LessonModel>> fetchLessons(int courseId) async {
    final data = await _api.get('/lessons/alllessons?courseid=$courseId');

    final List list = data['lessons'];
    return list.map((e) => LessonModel.fromJson(e)).toList();
  }
}
