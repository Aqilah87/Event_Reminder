import 'package:flutter/material.dart';
import '../models/event.dart';

class EventListPage extends StatelessWidget {
  final List<Event> events;

  EventListPage({required this.events});

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          'My Events',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 900),
            child: events.isEmpty
                ? Text(
                    'No events yet.',
                    style: TextStyle(fontSize: 18, color: Color(0xFF6B7280)),
                  )
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                        child: ListTile(
                          leading: Icon(Icons.event_note, color: Colors.black87),
                          title: Text(
                            event.title,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Date: ${_formatDate(event.date)}',
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}