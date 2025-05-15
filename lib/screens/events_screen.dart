import 'package:flutter/material.dart';
import 'package:my_app/screens/create_event_screen.dart';
import 'package:my_app/screens/event_details_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_app/widgets/event_card.dart';
import 'package:my_app/styles/styles.dart';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> events = [];
  Set<String> joinedEventIds = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _loadJoinedEvents();
  }

  Future<void> _loadEvents() async {
    final response = await supabase
        .from('events')
        .select('*, participants:participants(event_id)')
        .order('date');

    // response — список событий с массивом участников для каждого
    setState(() {
      events = response;
    });
  }

  Future<void> _loadJoinedEvents() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('participants')
        .select('event_id')
        .eq('user_id', user.id);

    final ids =
        (response as List<dynamic>)
            .map<String>((e) => e['event_id'] as String)
            .toSet();

    setState(() {
      joinedEventIds = ids;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Мероприятия')),
      body:
          events.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  final eventId = event['id'] as String;
                  final isJoined = joinedEventIds.contains(eventId);

                  return EventCard(
                    event: event,
                    isJoined: isJoined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailsScreen(event: event),
                        ),
                      ).then((_) => _loadEvents()); // обновим список, если надо
                    },
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: iconColor,
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateEventScreen()),
          ).then((_) {
            _loadEvents();
            _loadJoinedEvents();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
