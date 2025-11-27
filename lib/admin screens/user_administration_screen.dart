// user_administration_screen.dart

// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserAdministrationScreen extends StatefulWidget {
  final String email;
  const UserAdministrationScreen({super.key, required this.email});

  @override
  _UserAdministrationScreenState createState() => _UserAdministrationScreenState();
}

class _UserAdministrationScreenState extends State<UserAdministrationScreen> {
  final supabase = Supabase.instance.client;

  final emailController = TextEditingController();
  final passwordHashController = TextEditingController();
  final roleController = TextEditingController();
  final userUuidController = TextEditingController();

  bool _loading = false;
  bool _saving = false;

  Future<void> loadUserData() async {
    setState(() {
      _loading = true;
    });

    try {
      final user = await supabase
          .from('users')
          .select()
          .eq('email', widget.email)
          .maybeSingle();

      if (user != null) {
        emailController.text = user['email'] ?? '';
        passwordHashController.text = user['password_hash'] ?? '';
        roleController.text = user['role'] ?? '';
        userUuidController.text = user['user_uuid'] ?? '';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пользователь не найден')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки данных: $error')),
      );
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> saveUserData() async {
    setState(() {
      _saving = true;
    });

    try {
      final updates = {
        'password_hash': passwordHashController.text.trim(),
        'role': roleController.text.trim(),
        'user_uuid': userUuidController.text.trim(),
      };

      final response = await supabase
          .from('users')
          .update(updates)
          .eq('email', emailController.text.trim());
        

      if (response.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Данные успешно сохранены')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при сохранении: ${response.error!.message}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении: $error')),
      );
    }

    setState(() {
      _saving = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
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
              child: Column(
                children: [
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    readOnly: true, // email делаем нередактируемым
                  ),
                  TextFormField(
                    controller: passwordHashController,
                    decoration: const InputDecoration(labelText: 'Password Hash'),
                  ),
                  TextFormField(
                    controller: roleController,
                    decoration: const InputDecoration(labelText: 'Role'),
                  ),
                  TextFormField(
                    controller: userUuidController,
                    decoration: const InputDecoration(labelText: 'User UUID'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saving ? null : saveUserData,
                    child: Text(_saving ? 'Сохраняем...' : 'Сохранить'),
                  ),
                ],
              ),
            ),
    );
  }
}
