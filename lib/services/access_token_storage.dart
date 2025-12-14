import 'package:shared_preferences/shared_preferences.dart';

class AccessTokenStorage {
  static const _accessTokenKey = 'access_token';

  /// Сохранить токен
  static Future<void> save(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
  }

  /// Получить токен
  static Future<String?> get() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Проверка авторизации
  static Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_accessTokenKey);
  }

  /// Удалить токен (logout)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
  }
}
