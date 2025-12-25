import 'package:flutter/material.dart';
import 'users_screen/auth_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


    try {
    // Загружаем переменные окружения из .env файла
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // Если файл .env не найден, используем значения по умолчанию
    print('Warning: .env file not found. Using default values.');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home:  AuthPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
