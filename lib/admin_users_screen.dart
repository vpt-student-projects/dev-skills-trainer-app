// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_administration_screen.dart';
import 'theme.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  _AdminUsersScreenState createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final supabase = Supabase.instance.client;
  List<String> emails = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await supabase.from('users').select('email') as List<dynamic>;
      setState(() {
        emails = data.map((e) => e['email'] as String).toList();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при загрузке пользователей'),
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
        title: const Text('Список пользователей'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchUsers,
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : emails.isEmpty
              ? Center(
                  child: Text(
                    'Пользователи не найдены',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: emails.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.secondaryText,
                          child: Text(
                            emails[index][0].toUpperCase(),
                            style: const TextStyle(color: AppColors.secondary),
                          ),
                        ),
                        title: Text(
                          emails[index],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserAdministrationScreen(email: emails[index]),
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
