import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final supabase = Supabase.instance.client;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> createAccount() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  final confirmPassword = _confirmPasswordController.text.trim();

  if (password != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Пароли не совпадают')),
    );
    return;
  }

  try {
    final res = await supabase.auth.signUp(email: email, password: password);
    if (res.user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось зарегистрироваться')),
      );
    }
  } on AuthException catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ошибка регистрации: ${error.message}')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Неизвестная ошибка: $e')),
    );
  }
}

Future<void> login() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  try {
    final res = await supabase.auth.signInWithPassword(email: email, password: password);
    if (res.user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось войти')),
      );
    }
  } on AuthException catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ошибка входа: ${error.message}')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Неизвестная ошибка: $e')),
    );
  }
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
                    Tab(text: "Создать аккаунт"),
                    Tab(text: "Войти"),
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
          "Создать аккаунт",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.secondaryText),
        ),
        const SizedBox(height: 4),
        Text(
          "Заполните форму ниже, чтобы начать.",
          style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
        ),
        const SizedBox(height: 24),
        _buildInputField(label: "Email", controller: _emailController),
        const SizedBox(height: 20),
        _buildInputField(label: "Пароль", isPassword: true, controller: _passwordController),
        const SizedBox(height: 20),
        _buildInputField(label: "Подтверждение пароля", isPassword: true, controller: _confirmPasswordController),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            onPressed: createAccount,
            child: const Text(
              "Зарегистрироваться",
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
          "Войти",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryText),
        ),
        const SizedBox(height: 24),
        _buildInputField(label: "Email", controller: _emailController),
        const SizedBox(height: 20),
        _buildInputField(label: "Пароль", isPassword: true, controller: _passwordController),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            onPressed: login,
            child: const Text(
              "Войти",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryText),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({required String label, bool isPassword = false, TextEditingController? controller}) {
    return TextField(
      controller: controller,
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
