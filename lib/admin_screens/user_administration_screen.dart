// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class UserAdministrationScreen extends StatefulWidget {
  final String email;
  const UserAdministrationScreen({super.key, required this.email});

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
    roleController.text = 'user';
    userUuidController.text = '00000000-0000-0000-0000-000000000000';

    setState(() {
      _loading = false;
    });
  }

  Future<void> _saveMockData() async {
    setState(() {
      _saving = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Данные (условно) сохранены')),
      );
    }

    setState(() {
      _saving = false;
    });
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
                      decoration: const InputDecoration(labelText: 'Email'),
                      readOnly: true,
                    ),
                    TextFormField(
                      controller: passwordHashController,
                      decoration: const InputDecoration(
                        labelText: 'Password Hash',
                      ),
                    ),
                    TextFormField(
                      controller: roleController,
                      decoration: const InputDecoration(labelText: 'Role'),
                    ),
                    TextFormField(
                      controller: userUuidController,
                      decoration:
                          const InputDecoration(labelText: 'User UUID'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saving ? null : _saveMockData,
                      child: Text(_saving ? 'Сохраняем...' : 'Сохранить'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
