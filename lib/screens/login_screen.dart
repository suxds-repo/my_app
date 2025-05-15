import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _supabase = Supabase.instance.client;

  Future<void> _signUp() async {
    try {
      final res = await _supabase.auth.signUp(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      if (res.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Письмо для подтверждения отправлено!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка регистрации: $e')));
    }
  }

  Future<void> _signIn() async {
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      if (res.user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка входа: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Вход / Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _email,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _password,
              decoration: InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _signIn, child: Text('Войти')),
            TextButton(onPressed: _signUp, child: Text('Регистрация')),
          ],
        ),
      ),
    );
  }
}
