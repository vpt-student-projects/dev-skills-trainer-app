// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'user_administration_screen.dart';
import '/theme.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  _AdminUsersScreenState createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<String> emails = [
    'user1@example.com',
    'user2@example.com',
    'user3@example.com',
  ];

  final bool _isLoading = false;

  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список пользователей'),
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
          : emails.isEmpty
              ? Center(
                  child: Text(
                    'Пользователи не найдены',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.secondaryText,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: emails.length,
                  itemBuilder: (context, index) {
                    final email = emails[index];
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
                        leading: CircleAvatar(
                          backgroundColor: AppColors.secondaryText,
                          child: Text(
                            email[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                        title: Text(
                          email,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserAdministrationScreen(email: email),
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
