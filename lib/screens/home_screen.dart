
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'event_list_page.dart';
import 'add_event_page.dart' as add_event_lib;
import 'calendar_page.dart';
import '../models/event.dart';
import '../models/event_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Navigate to Add Event Page via EventData Provider
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
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 42, 134, 191),
        title: const Text(
          'Home Screen',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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
        ],
      ),

      // Drawer Menu
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color.fromARGB(255, 42, 134, 191)),
            child: Text(
              'Menu',
              style: TextStyle(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Events', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EventListPage(),
            ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Calendar', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CalendarPage(),
            ),
              );
            },
          ),
          const Divider(),

          // 🔽Dropdown Categories
          ExpansionTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              ListTile(
            leading: const Icon(Icons.business, color: Colors.blue),
            title: const Text('Meeting'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate or filter Meeting category
            },
              ),
              ListTile(
            leading: const Icon(Icons.alarm, color: Colors.green),
            title: const Text('Reminder'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate or filter Reminder category
            },
              ),
              ListTile(
            leading: const Icon(Icons.cake, color: Colors.orange),
            title: const Text('Birthday'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate or filter Birthday category
            },
              ),
              ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: const Text('Anniversary'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate or filter Anniversary category
            },
              ),
              ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('All Events'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Reset category filter
            },
              ),
            ],
          ),
            ],
          ),
        ),

      // Body Content
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo on left
                Flexible(
                  flex: 1,
                  child: SizedBox(
                    height: 300,
                    child: Image.asset(
                      'assets/logo_reminder-removebg-preview.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // Text and button on right
                Flexible(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Your Event Now',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Plan your day perfectly with ease and speed. Get started by adding a new event now.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () => _navigateToAddEventPage(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          backgroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                          shadowColor: Colors.black26,
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
