import 'package:flutter/material.dart';
import '../models/event.dart';
import 'add_event_page.dart';

class EventListPage extends StatefulWidget {
  final List<Event> events;

  EventListPage({Key? key, required this.events}) : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  // Format date + time
  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

      // Get icon based on reminder type
  IconData _getIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'birthday':
        return Icons.cake;
      case 'meeting':
        return Icons.business_center;
      case 'anniversary':
        return Icons.favorite;
      case 'reminder':
        return Icons.notifications_active;
      default:
        return Icons.event_note_outlined;
    }
  }

  void _addEvent(Event newEvent) {
    setState(() {
      widget.events.add(newEvent);
    });
  }

  void _updateEvent(Event updatedEvent, int index) {
    setState(() {
      widget.events[index] = updatedEvent;
    });
  }

  void _deleteEvent(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red[700])),
            onPressed: () {
              setState(() {
                widget.events.removeAt(index);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Event deleted')),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToAddEvent({Event? eventToEdit, int? editIndex}) async {
    final result = await Navigator.push<Event>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventPage(event: eventToEdit),
      ),
    );

    if (result != null) {
      if (editIndex != null) {
        _updateEvent(result, editIndex);
      } else {
        _addEvent(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Events',
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 24),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: widget.events.isEmpty
              ? const Text(
                  'No events yet.',
                  style: TextStyle(fontSize: 18, color: Color(0xFF6B7280)),
                )
              : ListView.separated(
                  itemCount: widget.events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final event = widget.events[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      shadowColor: Colors.black12,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                        leading: Icon(
                           _getIcon(event.reminderType),
                           color: const Color(0xFF374151),
                           size: 32,
                           ),
                        title: Text(
                          event.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Date: ${_formatDate(event.date)}',
                            style: const TextStyle(
                                color: Color(0xFF6B7280), fontSize: 14),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: Colors.blueAccent),
                              tooltip: 'Edit Event',
                              onPressed: () =>
                                  _navigateToAddEvent(eventToEdit: event, editIndex: index),
                              splashRadius: 20,
                              hoverColor: Colors.blueAccent.withOpacity(0.1),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              tooltip: 'Delete Event',
                              onPressed: () => _deleteEvent(index),
                              splashRadius: 20,
                              hoverColor: Colors.redAccent.withOpacity(0.1),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEvent(),
        backgroundColor: const Color(0xFF2A86BF),
        tooltip: 'Add Event',
        child: const Icon(Icons.add),
      ),
    );
  }
}
