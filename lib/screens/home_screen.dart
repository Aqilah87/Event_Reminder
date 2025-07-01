import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'event_list_page.dart';
import 'add_event_page.dart' as add_event_lib;
import 'calendar_page.dart';
import '../models/event.dart';
import '../models/event_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigateToAddEventPage(BuildContext context) async {
    final eventData = Provider.of<EventData>(context, listen: false);

    final newEvent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => add_event_lib.AddEventPage(),
      ),
    );

    if (newEvent != null && newEvent is Event) {
      eventData.addEvent(newEvent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.purple.shade700, // SAME color for all modes
        title: const Text(
          'Home Screen',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
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
              decoration: BoxDecoration(
                color: Colors.purple.shade700, // SAME color for all modes
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Organize your day efficiently',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Events',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const EventListPage())),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Calendar',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CalendarPage())),
            ),
            const Divider(),
            ExpansionTile(
              leading: const Icon(Icons.category),
              title: const Text('Categories',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                ListTile(
                  leading: const Icon(Icons.business, color: Colors.blue),
                  title: const Text('Meeting'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.alarm, color: Colors.green),
                  title: const Text('Reminder'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.cake, color: Colors.orange),
                  title: const Text('Birthday'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.red),
                  title: const Text('Anniversary'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('All Events'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                        color: theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToAddEventPage(context),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text(
                        'Create New Event',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        backgroundColor: Colors.purple.shade700, // Same color
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Divider(
                      thickness: 1,
                      color: theme.dividerColor.withOpacity(0.3),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your day made easy with Event Reminder',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Access your events, calendar, and reminders through the side menu.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
