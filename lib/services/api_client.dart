import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:vpt_learn/services/access_token_storage.dart';

class ApiClient {
  final String? baseUrl = dotenv.env['SERVER_URL'];

  /// GET
  Future<Map<String, dynamic>> get(String path) async {
    final token = await AccessTokenStorage.getAccessToken();
    final refreshtoken = await AccessTokenStorage.getRefreshToken();
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        if(refreshtoken != null) 'X-Refresh-Token': refreshtoken,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('API error ${response.statusCode}');
    }

    return response.body.isNotEmpty ? jsonDecode(response.body) : {};
  }

  /// POST
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic>? body) async {
    final token = await AccessTokenStorage.getAccessToken();
    final refreshtoken = await AccessTokenStorage.getRefreshToken();

    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        if(refreshtoken != null) 'X-Refresh-Token': refreshtoken,

      },
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode != 200) {
      throw Exception('API error ${response.statusCode}');
    }

    return response.body.isNotEmpty ? jsonDecode(response.body) : {};
  }

  /// PUT
  Future<Map<String, dynamic>> put(String path, Map<String, dynamic>? body) async {
    final token = await AccessTokenStorage.getAccessToken();
    final refreshtoken = await AccessTokenStorage.getRefreshToken();
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        if(refreshtoken != null) 'X-Refresh-Token': refreshtoken,

      },
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode != 200) {
      throw Exception('API error ${response.statusCode}');
    }

    return response.body.isNotEmpty ? jsonDecode(response.body) : {};
  }

  /// DELETE
  Future<Map<String, dynamic>> delete(String path) async {
    final token = await AccessTokenStorage.getAccessToken();
    final refreshtoken = await AccessTokenStorage.getRefreshToken();
    final response = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        if(refreshtoken != null) 'X-Refresh-Token': refreshtoken,

      },
    );

    if (response.statusCode != 200) {
      throw Exception('API error ${response.statusCode}');
    }

    return response.body.isNotEmpty ? jsonDecode(response.body) : {};
  }
}
