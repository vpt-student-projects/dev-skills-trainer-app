
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class AuthService {
  final String? baseUrl = dotenv.env['SERVER_URL']; 

  Future<Map<String, dynamic>?> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
      
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);

    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Ошибка регистрации');
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Ошибка логина');
    }
  }

  Future<void> signOut(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signout'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Ошибка выхода');
    }
  }
}
