import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  EventDetailsScreen({required this.event});

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> participants = [];
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    final data = await supabase
        .from('participants')
        .select('user_id')
        .eq('event_id', widget.event['id']);
    setState(() {
      participants = data;
    });
  }

  Future<void> _joinEvent() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final eventLogin = widget.event['login'];
    final eventPassword = widget.event['password'];
    final maxUsers = widget.event['max_users'];

    if (_loginController.text != eventLogin ||
        _passwordController.text != eventPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Неверный логин или пароль')));
      return;
    }

    final alreadyJoined = participants.any((p) => p['user_id'] == userId);
    if (alreadyJoined) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Вы уже присоединились к событию')),
      );
      return;
    }

    if (participants.length >= maxUsers) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Достигнут лимит участников')));
      return;
    }

    setState(() {
      _isJoining = true;
    });

    try {
      await supabase.from('participants').insert({
        'event_id': widget.event['id'],
        'user_id': userId,
      });
      await _loadParticipants();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Вы присоединились к мероприятию!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при присоединении к мероприятию')),
      );
    } finally {
      setState(() {
        _isJoining = false;
      });
    }
  }

  Future<void> _leaveEvent() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await supabase
          .from('participants')
          .delete()
          .eq('event_id', widget.event['id'])
          .eq('user_id', userId);

      await _loadParticipants();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Вы вышли из мероприятия')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выходе из мероприятия')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final joined = participants.any(
      (p) => p['user_id'] == supabase.auth.currentUser?.id,
    );

    return Scaffold(
      appBar: AppBar(title: Text(event['title'])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (event['image_url'] != null &&
                event['image_url'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  event['image_url'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 12.0,
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.description),
                      title: Text('Описание'),
                      subtitle: Text(event['description'] ?? 'Нет описания'),
                    ),
                    ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text('Адрес'),
                      subtitle: Text(event['adress'] ?? 'Не указан'),
                    ),
                    ListTile(
                      leading: Icon(Icons.date_range),
                      title: Text('Дата'),
                      subtitle: Text(_formatDate(event['date'])),
                    ),
                    ListTile(
                      leading: Icon(Icons.access_time),
                      title: Text('Время'),
                      subtitle: Text(
                        '${_formatTime(event['event_start'])} - ${_formatTime(event['event_end'])}',
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.group),
                      title: Text('Участники'),
                      subtitle: Text(
                        '${participants.length} / ${event['max_users']}',
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('Статус'),
                      subtitle: Text(event['status']),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            if (!joined) ...[
              TextField(
                controller: _loginController,
                decoration: InputDecoration(
                  labelText: 'Логин',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isJoining ? null : _joinEvent,
                  child:
                      _isJoining
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Text('Присоединиться'),
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Вы уже участвуете в этом мероприятии',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _leaveEvent,
                  child: Text('Выйти из мероприятия'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final hour = parts[0].padLeft(2, '0');
      final minute = parts[1].padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      return timeStr;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}.'
          '${date.month.toString().padLeft(2, '0')}.'
          '${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
