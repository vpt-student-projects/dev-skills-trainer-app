// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '/theme.dart';

class AdminLessonsScreen extends StatefulWidget {
  final int courseId;

  const AdminLessonsScreen({
    super.key,
    required this.courseId,
  });

  @override
  _AdminLessonsScreenState createState() => _AdminLessonsScreenState();
}

class _AdminLessonsScreenState extends State<AdminLessonsScreen> {
  List<String> lessons = [
    'Урок 1',
    'Урок 2',
    'Урок 3',
  ];

  final bool _isLoading = false;

  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список уроков'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : lessons.isEmpty
              ? Center(
                  child: Text(
                    'Уроки не найдены',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.secondaryText,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          lessons[index],
                          style:
                              const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onTap: () {
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
