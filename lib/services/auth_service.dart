
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:vpt_learn/services/api_client.dart';


// class AuthService {
//   final String? baseUrl = dotenv.env['SERVER_URL']; 
//   final ApiClient _api = ApiClient();
//   Future<Map<String, dynamic>?> register(String email, String password) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/register'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'email': email, 'password': password}),
      
//     );

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);

//     } else {
//       throw Exception(jsonDecode(response.body)['error'] ?? 'Ошибка регистрации');
//     }
//   }

//   Future<Map<String, dynamic>?> login(String email, String password) async {
//     final response = _api.get('/courses/allcourses');

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception(jsonDecode(response.body)['error'] ?? 'Ошибка логина');
//     }
//   }

//   Future<void> signOut(String email, String password) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/signout'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'email': email, 'password': password}),
//     );

//     if (response.statusCode != 200) {
//       throw Exception(jsonDecode(response.body)['error'] ?? 'Ошибка выхода');
//     }
//   }
// }
import 'package:vpt_learn/services/api_client.dart';
import 'package:vpt_learn/services/access_token_storage.dart';

class AuthService {
  final ApiClient _api = ApiClient();

  /// Регистрация
  Future<Map<String, dynamic>> register(String email, String password) async {
    final data = await _api.post('/auth/register', {'email': email, 'password': password});

    // Сохраняем access token
    if (data['accessToken'] != null) {
      await AccessTokenStorage.save(data['accessToken']);
    }

    return data;
  }

  /// Логин
  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _api.post('/auth/login', {'email': email, 'password': password});

    // Сохраняем access token
    if (data['accessToken'] != null) {
      await AccessTokenStorage.save(data['accessToken']);
    }

    return data;
  }

  /// Выход
  Future<void> signOut() async {
    await _api.post('/auth/signout', null);

    // Очистка токена
    await AccessTokenStorage.clear();
  }
}
