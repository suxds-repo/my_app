import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'events_screen.dart';
import 'joined_events_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _logout() async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      EventsScreen(), // убрали onLogout
      JoinedEventsScreen(),
      SettingsScreen(onLogout: _logout), // передаём onLogout сюда
    ];

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'События'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Мои'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}
