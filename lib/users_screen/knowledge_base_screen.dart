import 'package:flutter/material.dart';
import 'package:vpt_learn/services/api_client.dart';
import '../theme.dart';

class KnowledgeBasePage extends StatelessWidget {
  const KnowledgeBasePage({super.key});

  final List<String> languages = const [
    'Dart', 'Python', 'JavaScript', 'C#', 'Java', 'C++'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('База знаний'),
        backgroundColor: AppColors.secondary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final language = languages[index];
          return Card(
            color: AppColors.secondary.withValues(alpha: 0.8),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                language,
                style: const TextStyle(fontSize: 20, color: AppColors.primaryText),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white54),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LanguageDetailScreen(language: language),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class LanguageDetailScreen extends StatefulWidget {
  final String language;
  const LanguageDetailScreen({super.key, required this.language});

  @override
  State<LanguageDetailScreen> createState() => _LanguageDetailScreenState();
}

class _LanguageDetailScreenState extends State<LanguageDetailScreen> {
  late Future<Map<String, dynamic>> _data;
  final ApiClient _api = ApiClient();

  @override
  void initState() {
    super.initState();
    _data = _api.get('/knowledgebase/${widget.language}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text(widget.language),
        backgroundColor: AppColors.secondary,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Ошибка: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? widget.language,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.alternate,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  data['description'] ?? 'Описание не найдено',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Пример кода:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.alternate,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    data['example'] ?? '// Пример не найден',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}