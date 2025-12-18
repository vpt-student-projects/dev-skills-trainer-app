// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:vpt_learn/models/user_model.dart';
import 'package:vpt_learn/services/admin_users_service.dart';

class UserAdministrationScreen extends StatefulWidget {
  final String email;
  final String userUuid;
  final String? role;
  const UserAdministrationScreen({super.key, required this.email, required this.userUuid, this.role});


  @override
  _UserAdministrationScreenState createState() =>
      _UserAdministrationScreenState();
}

class _UserAdministrationScreenState extends State<UserAdministrationScreen> {
  final emailController = TextEditingController();
  final passwordHashController = TextEditingController();
  final roleController = TextEditingController();
  final userUuidController = TextEditingController();
  
  bool _loading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    setState(() {
      _loading = true;
    });
    emailController.text = widget.email;
    passwordHashController.text = '';
    roleController.text = widget.role ?? 'студент';
    userUuidController.text = widget.userUuid;


    setState(() {
      _loading = false;
    });
  }

Future<void> _save() async {
  if (_saving) return;

  setState(() => _saving = true);

  try {
    await AdminUsersService().updateUser(
      AdminUpdateUserRequest(
        userUuid: widget.userUuid,
        newEmail: emailController.text.trim(),
        newPassword: passwordHashController.text.isEmpty
            ? ""
            : passwordHashController.text.trim(),
      ),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Пользователь обновлён')),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ошибка: $e')),
    );
  } finally {
    if (mounted) setState(() => _saving = false);
  }
}


  @override
  void dispose() {
    emailController.dispose();
    passwordHashController.dispose();
    roleController.dispose();
    userUuidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Данные пользователя'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Новый email'),
                    ),
                    TextFormField(
                      controller: passwordHashController,
                      decoration: const InputDecoration(
                        labelText: 'Новый пароль',
                      ),
                    ),
                    TextFormField(
                      controller: roleController,
                      decoration: const InputDecoration(labelText: 'Роль'),
                    ),
                    TextFormField(
                      controller: userUuidController,
                      decoration: const InputDecoration(labelText: 'User UUID'),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: Text(_saving ? 'Изменяем...' : 'Изменить'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
