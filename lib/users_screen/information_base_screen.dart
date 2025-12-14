import 'package:flutter/material.dart';
import '../theme.dart';

class KnowledgeBasePage extends StatelessWidget {
  const KnowledgeBasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final languages = [
  {
    'name': 'Dart', 
  },
  {
    'name': 'Python', 
  },
  {
    'name': 'JavaScript', 
  },
  {
    'name': 'C#',
  },
  {
    'name': 'Java',},
  {
    'name': 'C++',
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
                style: const TextStyle(fontSize: 20, color: AppColors.primaryText),
              ),
            ),
          );
        },
      ),
    );
  }
}
