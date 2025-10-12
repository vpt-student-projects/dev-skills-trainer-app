import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'theme.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white12,
                  child: const Icon(Icons.book, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 14),
                const Text(
                  "VPTLearn",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 18),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: "Create Account"),
                    Tab(text: "Log In"),
                  ],
                  indicatorColor: AppColors.alternate,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCreateAccount(),
                      _buildLogin(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateAccount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Create Account",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.secondaryText),
        ),
        const SizedBox(height: 4),
        Text(
          "Let's get started by filling out the form below.",
          style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
        ),
        const SizedBox(height: 24),
        _buildInputField(label: "Email"),
        const SizedBox(height: 20),
        _buildInputField(label: "Password", isPassword: true),
        const SizedBox(height: 20),
        _buildInputField(label: "Confirm password", isPassword: true),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            child: const Text(
              "Get Started",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Log In",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryText),
        ),
        const SizedBox(height: 24),
        _buildInputField(label: "Email"),
        const SizedBox(height: 20),
        _buildInputField(label: "Password", isPassword: true),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            child: const Text(
              "Log In",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryText),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({required String label, bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.secondaryBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? Icon(Icons.visibility_off, color: AppColors.secondaryText)
            : null,
        labelStyle: TextStyle(color: AppColors.secondaryText),
      ),
      style: TextStyle(color: AppColors.primaryText),
    );
  }
}
