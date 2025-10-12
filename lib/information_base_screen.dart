import 'package:flutter/material.dart';
import 'theme.dart';

class KnowledgeBasePage extends StatelessWidget {
  const KnowledgeBasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('База знаний'),
        backgroundColor: AppColors.secondary,
      ),
      body: const Center(
        child: Text(
          'Раздел База знаний',
          style: TextStyle(fontSize: 24, color: Colors.white70),
        ),
      ),
    );
  }
}
