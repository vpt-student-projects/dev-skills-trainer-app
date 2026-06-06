import 'package:flutter/material.dart';
import '../theme.dart';
import 'admin_courses_screen.dart';
import 'admin_users_screen.dart';
import 'package:vpt_learn/users_screen/profile_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Widget> _pages = const [
    AdminUsersScreen(),
    AdminCoursesScreen(),
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
        backgroundColor: AppColors.primaryBackground,
        selectedItemColor: AppColors.alternate,
        unselectedItemColor: AppColors.secondaryText,
        onTap: (index) {
          _tabController.animateTo(index); // ← анимация
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Пользователи',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Курсы',
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