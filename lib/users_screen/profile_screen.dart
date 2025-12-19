import 'package:flutter/material.dart';
import 'auth_screen.dart';
import '../theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
            _buildSettingsItem(
              icon: Icons.logout,
              title: 'Log out of account',
              trailingText: 'Log Out?',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? trailingText,
    IconData? trailingIcon,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: AppColors.secondaryText),
          title: Text(title, style: TextStyle(color: AppColors.primaryText)),
          trailing: trailingIcon != null
              ? Icon(trailingIcon, color: AppColors.secondaryText, size: 20)
              : (trailingText != null
                  ? Text(trailingText, style: TextStyle(color: AppColors.secondaryText))
                  : null),
          onTap: onTap,
        ),
        const Divider(color: AppColors.secondary, height: 1),
      ],
    );
  }
}
