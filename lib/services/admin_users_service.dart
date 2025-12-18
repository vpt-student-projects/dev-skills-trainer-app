import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vpt_learn/models/course_model.dart';
import 'package:vpt_learn/models/user_model.dart';
import 'package:vpt_learn/services/api_client.dart';

class AdminUsersService {
  final ApiClient _api = ApiClient();

  Future<List<AdminUser>> fetchUsers() async {
    final response = await _api.get('/admin/users');

    final List list = response['users']; // ← КЛЮЧЕВО
    return list.map((e) => AdminUser.fromJson(e)).toList();
  }
    Future<void> updateUser(AdminUpdateUserRequest request) async {
    await _api.post(
      '/admin/update-user-auth',
      request.toJson(),
    );
  }
}
