// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';

class AdminCoursesScreen extends StatefulWidget {
  const AdminCoursesScreen({super.key});

  @override
  _AdminCoursesScreenState createState() => _AdminCoursesScreenState();
}

class _AdminCoursesScreenState extends State<AdminCoursesScreen> {
  final supabase = Supabase.instance.client;
  List<String> courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await supabase.from('courses').select('title') as List<dynamic>;
      setState(() {
        courses = data.map((e) => e['title'] as String).toList();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при загрузке курсов'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список курсов'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchCourses,
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : courses.isEmpty
              ? Center(
                  child: Text(
                    'Курсы не найдены',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.secondaryText,
                          child: Text(
                            courses[index][0].toUpperCase(),
                            style: const TextStyle(color: AppColors.secondary),
                          ),
                        ),
                        title: Text(
                          courses[index],
                          style: const TextStyle(fontWeight: FontWeight.w600),
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
