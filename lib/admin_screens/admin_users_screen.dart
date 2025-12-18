// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:vpt_learn/models/user_model.dart';
import 'package:vpt_learn/services/admin_users_service.dart';
import 'user_administration_screen.dart';
import '/theme.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  _AdminUsersScreenState createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
 List<AdminUser> _users = [];
   bool _isLoading = false;
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _users = await AdminUsersService().fetchUsers();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _loadUsers();
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
          : _users.isEmpty
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
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    final email = user.email;
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
                              builder: (_) => UserAdministrationScreen(
                                userUuid: user.userUuid,
                                email: user.email,
                                role: user.role,
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
