
import 'package:vpt_learn/services/api_client.dart';
import 'package:vpt_learn/services/access_token_storage.dart';

class AuthService {
  final ApiClient _api = ApiClient();

  /// Регистрация
  Future<Map<String, dynamic>> register(String email, String password) async {
    final data = await _api.post('/auth/register', {'email': email, 'password': password});

    // Сохраняем access token
    if (data['accessToken'] != null) {
    await AccessTokenStorage.saveTokens(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );
    }

    return data;
  }

  /// Логин
  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _api.post('/auth/login', {'email': email, 'password': password});

    // Сохраняем access token
    if (data['accessToken'] != null) {
      await AccessTokenStorage.saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
    }

    return data;
  }

  Future<void> signOut() async {
    await _api.post('/auth/signout', null);

    // Очистка токена
    await AccessTokenStorage.clear();
  }
}
