import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_app/widgets/event_card.dart'; // Подключаем общий виджет карточки
import 'package:my_app/screens/event_details_screen.dart'; // Для перехода в детали
import 'package:my_app/styles/styles.dart';

class JoinedEventsScreen extends StatefulWidget {
  @override
  _JoinedEventsScreenState createState() => _JoinedEventsScreenState();
}

class _JoinedEventsScreenState extends State<JoinedEventsScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> joinedEvents = [];

  @override
  void initState() {
    super.initState();
    _loadJoinedEvents();
  }

  Future<void> _loadJoinedEvents() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // Запрашиваем свои записи с полными данными событий и их участниками
    final response = await supabase
        .from('participants')
        .select('event_id, events(*, participants(event_id))')
        .eq('user_id', user.id);

    setState(() {
      joinedEvents =
          response.map((e) {
            final event = e['events'];
            // Убедимся, что participants — список участников события
            event['participants'] = event['participants'] ?? [];
            return event;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Мои мероприятия')),
      body:
          joinedEvents.isEmpty
              ? Center(
                child: Text(
                  'Вы пока не записаны ни на одно мероприятие',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: joinedEvents.length,
                itemBuilder: (context, index) {
                  final event = joinedEvents[index];
                  return EventCard(
                    event: event,
                    isJoined: true, // отмечаем, что пользователь записан
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailsScreen(event: event),
                        ),
                      );
                    },
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: iconColor,
                    ),
                  );
                },
              ),
    );
  }
}
