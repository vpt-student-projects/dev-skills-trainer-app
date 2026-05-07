import 'package:flutter/material.dart';
import 'users_screen/auth_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true; // Всегда доверять
  }
}


void main() async {
  HttpOverrides.global = MyHttpOverrides();
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
      home:  AuthScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
