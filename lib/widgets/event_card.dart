import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final Map event;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool isJoined;

  const EventCard({
    required this.event,
    required this.onTap,
    this.trailing,
    this.isJoined = false,
    Key? key,
  }) : super(key: key);

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    } catch (_) {
      return timeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = event['image_url'];
    final maxUsers = event['max_users'] ?? 0;
    final participantsList = event['participants'] as List<dynamic>? ?? [];
    final participantsCount = participantsList.length;

    double progress = 0;
    if (maxUsers > 0) {
      progress = participantsCount / maxUsers;
      if (progress > 1) progress = 1;
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.symmetric(vertical: 10),
        elevation: 4,
        child: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(
                              imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                            : Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event['title'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isJoined)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Записан',
                                  style: TextStyle(
                                    color: Colors.green[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text('📅 ${_formatDate(event['date'])}'),
                        Text(
                          '🕒 ${_formatTime(event['event_start'])} – ${_formatTime(event['event_end'])}',
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),

              if (maxUsers > 0) ...[
                SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  color: Colors.blue,
                  minHeight: 6,
                ),
                SizedBox(height: 4),
                Text(
                  '$participantsCount из $maxUsers мест занято',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
