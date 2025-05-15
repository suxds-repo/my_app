import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onLogout;

  SettingsScreen({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Настройки')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user != null) ...[
                Icon(Icons.account_circle, size: 64, color: Colors.grey[700]),
                SizedBox(height: 12),
                Text(
                  user.email ?? 'Нет email',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
              ],
              ElevatedButton.icon(
                icon: Icon(Icons.logout),
                label: Text('Выйти из аккаунта'),
                onPressed: onLogout,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
