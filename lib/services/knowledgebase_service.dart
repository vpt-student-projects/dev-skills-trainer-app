import 'package:vpt_learn/models/language_model.dart';
import 'package:vpt_learn/services/api_client.dart';

class KnowledgeBaseService {
  final ApiClient _api = ApiClient();

  // Получение всех языков
  Future<List<LanguageModel>> getAllLanguages() async {
    final response = await _api.get('/knowledgebase');
    
    // Обработка ответа в формате: { "languagedata": [...] }
    if (response is Map<String, dynamic> && response.containsKey('languagedata')) {
      final List<dynamic> languagesList = response['languagedata'];
      return languagesList.map((json) => LanguageModel.fromJson(json)).toList();
    }
    
    // Альтернативный формат: если ответ - просто массив
    // if (response is List) {
    //   return response.map((json) => LanguageModel.fromJson(json)).toList();
    // }
    
    throw Exception('Unexpected response format: $response');
  }
}