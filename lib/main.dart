import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/event_list_page.dart';
//import 'package:reminder_test/screens/add_event_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Reminder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.black87,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 48,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 18,
            color: Color(0xFF6B7280),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 4,
            shadowColor: Colors.black26,
          ),
        ),
      ),
      home: const HomeScreen(),
      routes: {
        '/events': (context) =>
            EventListPage(events: []), // Pass real event list here
        '/add-event': (context) => const AddEventPage(),
      },
    );
  }
}

class AddEventPage extends StatelessWidget {
  const AddEventPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event'),
      ),
      body: const Center(
        child: Text('Add Event Page'),
      ),
    );
  }
}
