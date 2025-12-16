import 'package:vpt_learn/models/course_model.dart';
import 'package:vpt_learn/services/api_client.dart';

class CourseService {
  final ApiClient _api = ApiClient();

  Future<List<CourseModel>> fetchCourses() async {
    final data = await _api.get('/courses/allcourses');

    final List list = data['courses'];
    return list.map((e) => CourseModel.fromJson(e)).toList();
  }
}
