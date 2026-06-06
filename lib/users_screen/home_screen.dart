import 'package:flutter/material.dart';
import 'courses_screen.dart';
import 'profile_screen.dart';
import 'information_base_screen.dart';
import '../theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Widget> _pages = const [
    LearningTab(),
    KnowledgeBasePage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabController.index,
        onTap: (index) {
          _tabController.animateTo(index); // ← анимация
        },
        backgroundColor: AppColors.primaryBackground,
        selectedItemColor: AppColors.alternate,
        unselectedItemColor: AppColors.secondaryText,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Обучение',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'База знаний',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}