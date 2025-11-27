import 'package:flutter/material.dart';
import '../theme.dart';

class KnowledgeBasePage extends StatelessWidget {
  const KnowledgeBasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final languages = [
  {
    'name': 'Dart',
    'logo': 'https://upload.wikimedia.org/wikipedia/commons/7/7e/Dart-logo.png',
  },
  {
    'name': 'Python',
    'logo': '',
  },
  {
    'name': 'JavaScript',
    'logo': 'https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png',
  },
  {
    'name': 'C#',
    'logo': 'https://upload.wikimedia.org/wikipedia/commons/4/4f/Csharp_Logo.png',
  },
  {
    'name': 'Java',
    'logo': 'https://img.icons8.com/color/48/000000/java-coffee-cup-logo.png',
  },
  {
    'name': 'C++',
    'logo': '',
  },
];


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
              leading: Image.network(
                language['logo']!,
                width: 40,
                height: 40,
              ),
              title: Text(
                language['name']!,
                style: const TextStyle(fontSize: 20, color: Colors.white70),
              ),
            ),
          );
        },
      ),
    );
  }
}
