import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io'; // Import dart:io for File
import 'event_list_page.dart';
import 'add_event_page.dart' as add_event_lib;
import 'calendar_page.dart';
import '../models/event.dart';
import '../models/event_data.dart';
import '../widgets/in_app_noti.dart';
import 'dart:async'; // ✅ Needed for Timer

class EventSearchDelegate extends SearchDelegate<Event?> {
  final List<Event> events;

  EventSearchDelegate(this.events);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = events
        .where(
            (event) => event.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final event = results[index];
        return ListTile(
          title: Text(event.title),
          subtitle: Text(event.description ?? ''),
          onTap: () => close(context, event),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = events
        .where(
            (event) => event.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final event = suggestions[index];
        return ListTile(
          title: Text(event.title),
          onTap: () {
            query = event.title;
            showResults(context);
          },
        );
      },
    );
  }
}

  class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key});

    @override
    State<HomeScreen> createState() => _HomeScreenState();
  }

  class _HomeScreenState extends State<HomeScreen> {
    void _navigateToAddEvent(BuildContext context, EventData eventData,
        {Event? eventToEdit}) async {
      print('HomeScreen: --- Starting _navigateToAddEvent ---');
      print('HomeScreen: Passed event to AddEventPage for edit: "${eventToEdit?.title}", Its Key: ${eventToEdit?.key}');

      final result = await Navigator.push<Map<String, dynamic>?>(
        context,
        MaterialPageRoute(
            builder: (_) => add_event_lib.AddEventPage(event: eventToEdit)),
      );

      if (result != null) {
        final newEvent = result['event'] as Event;
        final oldEventKey = result['key'] as int?;
        print('HomeScreen: Returned from AddEventPage. New event title: "${newEvent.title}", Original Key received: $oldEventKey');

        if (oldEventKey != null) {
          await eventData.updateEvent(oldEventKey, newEvent);
          showNotification(context, "✅ Event updated successfully!");
          scheduleInAppNotification(context, newEvent.dateTime,
              "⏰ It's time for your appointment: ${newEvent.title}");
        } else {
          await eventData.addEvent(newEvent);
          showNotification(context, "🎉 New event added!");
          scheduleInAppNotification(context, newEvent.dateTime,
              "⏰ It's time for your appointment: ${newEvent.title}");
        }
      } else {
        print('HomeScreen: Returned from AddEventPage with null result.');
      }

      print('HomeScreen: --- Finished _navigateToAddEvent ---');
    }

    void _deleteEvent(BuildContext context, Event event, EventData eventData) {
      print('HomeScreen: Initiating delete for event: "${event.title}", Key: ${event.key}');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Event'),
          content: const Text('Are you sure you want to delete this event?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                print('HomeScreen: Delete cancelled.');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red.shade700)),
              onPressed: () {
                print('HomeScreen: Confirmed delete for event: "${event.title}", Key: ${event.key}');
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

    void showNotification(BuildContext context, String message) {
      final overlay = Overlay.of(context);
      if (overlay == null) {
        print("⚠️ Overlay is null. Notification can't be shown.");
        return;
      }

      late OverlayEntry entry;
      entry = OverlayEntry(
        builder: (context) => Stack(
          children: [
            InAppNotification(
              message: message,
              onDismiss: () => entry.remove(),
            ),
          ],
        ),
      );

      overlay.insert(entry);
      Future.delayed(const Duration(seconds: 3), () => entry.remove());
    }

    void scheduleInAppNotification(BuildContext context, DateTime scheduledTime, String message) {
      final now = DateTime.now();
      final delay = scheduledTime.difference(now);

      if (delay.inSeconds > 0) {
        Timer(delay, () {
          if (mounted) {
            showNotification(context, message);
            print("✅ Notification triggered at ${DateTime.now()}");
          }
        });
        print("⏳ Notification scheduled in ${delay.inSeconds} seconds.");
      } else {
        print("⚠️ Scheduled time already passed. No notification scheduled.");
      }
    }

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
        case 'other':
          return Icons.event_note;
        default:
          return Icons.event_note_outlined;
      }
    }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.purple.shade700,
        title: const Text(
          'Home Screen',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              final eventData = Provider.of<EventData>(context, listen: false);
              showSearch(
                context: context,
                delegate: EventSearchDelegate(eventData.events),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.purple.shade700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Organize your day efficiently',
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(context, Icons.home, 'Home', () {
              Navigator.pop(context);
            }),
            _buildDrawerItem(context, Icons.event, 'Events', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EventListPage()),
              );
            }),
            _buildDrawerItem(context, Icons.calendar_today, 'Calendar', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalendarPage()),
              );
            }),
            const Divider(),
            ExpansionTile(
              leading: const Icon(Icons.category),
              title: const Text('Categories',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                _buildDrawerItem(context, Icons.business, 'Meeting', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const EventListPage(categoryFilter: 'Meeting'),
                    ),
                  );
                }, iconColor: Colors.blue),
                _buildDrawerItem(context, Icons.alarm, 'Reminder', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const EventListPage(categoryFilter: 'Reminder'),
                    ),
                  );
                }, iconColor: Colors.green),
                _buildDrawerItem(context, Icons.cake, 'Birthday', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const EventListPage(categoryFilter: 'Birthday'),
                    ),
                  );
                }, iconColor: Colors.orange),
                _buildDrawerItem(context, Icons.favorite, 'Anniversary', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const EventListPage(categoryFilter: 'Anniversary'),
                    ),
                  );
                }, iconColor: Colors.red),
                _buildDrawerItem(context, Icons.event_note, 'Other', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const EventListPage(categoryFilter: 'Other'),
                    ),
                  );
                }, iconColor: Colors.grey),
                _buildDrawerItem(context, Icons.refresh, 'All Events', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const EventListPage(categoryFilter: 'All Events'),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Welcome section
            Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 160,
                    child: Image.asset(
                      'assets/logo_reminder-removebg-preview.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome to Event Reminder',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Stay on top of your schedule. Easily plan, track, and get notified about your events all in one place.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToAddEvent(context,
                        Provider.of<EventData>(context, listen: false)),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text(
                      'Create New Event',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      backgroundColor: Colors.purple.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'All Events',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Event list
            Consumer<EventData>(
              builder: (context, eventData, _) {
                final events = List<Event>.from(eventData.events)
                  ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

                if (events.isEmpty) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'No events found. Add one to get started!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    print(
                        'HomeScreen: Building ListTile for event: "${event.title}", Key: ${event.key}');
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: event.imagePath != null &&
                                event.imagePath!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(event.imagePath!),
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(_getIcon(event.reminderType),
                                        color: Colors.purple.shade700);
                                  },
                                ),
                              )
                            : Icon(_getIcon(event.reminderType),
                                color: Colors.purple.shade700),
                        title: Text(event.title),
                        subtitle: Text(
                          '${event.dateTime.day.toString().padLeft(2, '0')}/${event.dateTime.month.toString().padLeft(2, '0')}/${event.dateTime.year}',
                        ),
                        onTap: () {
                          // Tapping the ListTile itself also navigates to edit
                          print(
                              'HomeScreen: ListTile tapped for event: "${event.title}", Key: ${event.key}');
                          _navigateToAddEvent(context, eventData,
                              eventToEdit: event);
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit_outlined,
                                  color: Colors.purple.shade700),
                              tooltip: 'Edit Event',
                              onPressed: () {
                                print(
                                    'HomeScreen: Edit icon tapped for event: "${event.title}", Key: ${event.key}');
                                _navigateToAddEvent(context, eventData,
                                    eventToEdit: event);
                              },
                              splashRadius: 20,
                              hoverColor:
                                  Colors.purple.shade700.withOpacity(0.1),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              tooltip: 'Delete Event',
                              onPressed: () {
                                print(
                                    'HomeScreen: Delete icon tapped for event: "${event.title}", Key: ${event.key}');
                                _deleteEvent(context, event, eventData);
                              },
                              splashRadius: 20,
                              hoverColor: Colors.redAccent.withOpacity(0.1),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap,
      {Color? iconColor}) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.black),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}
