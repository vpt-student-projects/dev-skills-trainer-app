import 'package:flutter/material.dart';
import '../theme.dart';

class KnowledgeBasePage extends StatelessWidget {
  const KnowledgeBasePage({super.key});

  final List<Map<String, String>> languages = const [
    {'name': 'Dart', 'description': '', 'example': ''},
    {'name': 'Python', 'description': '', 'example': ''},
    {'name': 'JavaScript', 'description': '', 'example': ''},
    {'name': 'C#', 'description': '', 'example': ''},
    {'name': 'Java', 'description': '', 'example': ''},
    {'name': 'C++', 'description': '', 'example': ''},
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
                language['name']!,
                style: const TextStyle(fontSize: 20, color: AppColors.primaryText),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white54),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LanguageDetailScreen(
                      name: language['name']!,
                    ),
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

class LanguageDetailScreen extends StatelessWidget {
  final String name;

  const LanguageDetailScreen({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    // пока заглушка:
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text(name),
        backgroundColor: AppColors.secondary,
      ),
      body: const Center(
        child: Text(
          'Загрузка...\n\nAPI /languages/{name} ещё не готов',
          style: TextStyle(color: AppColors.primaryText),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}