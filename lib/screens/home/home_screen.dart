import 'package:flutter/material.dart';

import '../../widgets/bottom_nav_bar.dart';
import '../start/start_screen.dart';
import '../calendar/calendar_screen.dart';
import '../user/user_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [StartScreen(), CalendarScreen(), UserScreen()];

  final _items = const [
    NavItem(icon: Icons.home_outlined, activeIcon: Icons.home),
    NavItem(icon: Icons.event_outlined, activeIcon: Icons.event),
    NavItem(icon: Icons.schedule_outlined, activeIcon: Icons.schedule),
    NavItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
    ),
    NavItem(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book),
    NavItem(icon: Icons.person_outline, activeIcon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _items,
      ),
    );
  }
}
