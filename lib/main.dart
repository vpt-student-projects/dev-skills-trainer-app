import 'package:flutter/material.dart';
import 'users_screen/auth_screen.dart';
import 'users_screen/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/access_token_storage.dart';  // ← это новая строчка

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    print('Warning: .env file not found. Using default values.');
  }

  
  // Проверяем, входил ли пользователь раньше
  final isLoggedIn = await AccessTokenStorage.hasAccessToken();
  

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      
      home: isLoggedIn ? const HomeScreen() : const AuthScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}