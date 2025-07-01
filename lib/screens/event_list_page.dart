import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../models/event_data.dart';
import 'add_event_page.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({Key? key}) : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

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

  void _deleteEvent(Event event, EventData eventData) {
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
            child: Text('Delete', style: TextStyle(color: Colors.red.shade700)),
            onPressed: () {
              eventData.deleteEvent(event);
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

  Future<void> _navigateToAddEvent(EventData eventData,
      {Event? eventToEdit}) async {
    final result = await Navigator.push<Event>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventPage(event: eventToEdit),
      ),
    );

    if (result != null) {
      if (eventToEdit != null) {
        eventData.updateEvent(eventToEdit, result);
      } else {
        eventData.addEvent(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventData = Provider.of<EventData>(context);
    final allEvents = eventData.getAllEvents();
    final theme = Theme.of(context);
    final purple = Colors.purple.shade700;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Events',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        backgroundColor: purple,
        elevation: 2,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: allEvents.isEmpty
              ? Text(
                  'No events yet.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                )
              : ListView.separated(
                  itemCount: allEvents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final event = allEvents[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: Colors.black12,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                        leading: Icon(
                          _getIcon(event.reminderType),
                          color: purple,
                          size: 32,
                        ),
                        title: Text(
                          event.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Date: ${_formatDate(event.dateTime)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.6),
                            ),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit_outlined, color: purple),
                              tooltip: 'Edit Event',
                              onPressed: () => _navigateToAddEvent(eventData,
                                  eventToEdit: event),
                              splashRadius: 20,
                              hoverColor: purple.withOpacity(0.1),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              tooltip: 'Delete Event',
                              onPressed: () => _deleteEvent(event, eventData),
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
        onPressed: () => _navigateToAddEvent(eventData),
        backgroundColor: purple,
        tooltip: 'Add Event',
        child: const Icon(Icons.add),
      ),
    );
  }
}
