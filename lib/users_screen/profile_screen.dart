import 'package:flutter/material.dart';
import 'package:vpt_learn/services/api_client.dart';
import 'package:vpt_learn/services/access_token_storage.dart';
import 'auth_screen.dart';
import '../theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
  final current = _currentPasswordController.text.trim();
  final newPass = _newPasswordController.text.trim();
  final confirm = _confirmPasswordController.text.trim();

  if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Заполните все поля')),
    );
    return;
  }

  if (newPass != confirm) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Новые пароли не совпадают')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final api = ApiClient();
    Future<String> _getCurrentUserUuid() async {
  final api = ApiClient();
  final data = await api.get('/user/current');
  return data['userUuid']; // или 'uuid' — посмотри в swagger какой ключ
}

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Пароль успешно изменён')),
    );
    _cancelEdit();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ошибка: $e')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}

Future<String> _getCurrentUserUuid() async {
  final api = ApiClient();
  final data = await api.get('/user/current');
  return data['userUuid']; // или 'uuid' — проверь по swagger
}

  Future<void> _logout() async {
    await AccessTokenStorage.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white12,
              child: Icon(Icons.person, size: 60, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.primaryText.withAlpha(204),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (!_isEditing)
              _buildSettingsItem(
                icon: Icons.lock,
                title: 'Изменить пароль',
                trailingText: 'Сменить',
                onTap: () => setState(() => _isEditing = true),
              )
            else
              _buildPasswordForm(),
            _buildSettingsItem(
              icon: Icons.logout,
              title: 'Выйти из аккаунта',
              trailingText: 'Выйти',
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          TextField(
            controller: _currentPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Текущий пароль',
              border: OutlineInputBorder(),
            ),
            style: TextStyle(color: AppColors.primaryText),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Новый пароль',
              border: OutlineInputBorder(),
            ),
            style: TextStyle(color: AppColors.primaryText),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Подтвердить новый пароль',
              border: OutlineInputBorder(),
            ),
            style: TextStyle(color: AppColors.primaryText),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _cancelEdit,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Отмена'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.alternate),
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Сохранить'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: AppColors.secondaryText),
          title: Text(title, style: TextStyle(color: AppColors.primaryText)),
          trailing: trailingText != null
              ? Text(trailingText, style: TextStyle(color: AppColors.secondaryText))
              : null,
          onTap: onTap,
        ),
        const Divider(color: AppColors.secondary, height: 1),
      ],
    );
  }
}