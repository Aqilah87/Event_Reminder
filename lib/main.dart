import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'models/event.dart';
import 'models/event_data.dart';
import 'screens/home_screen.dart';
import 'screens/event_list_page.dart';
import 'screens/add_event_page.dart';
import 'screens/calendar_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocDir = await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);

  Hive.registerAdapter(EventAdapter());
  await Hive.openBox<Event>('events');

  runApp(
    ChangeNotifierProvider(
      create: (context) => EventData(),
      child: const MyApp(),
    ),
  );
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
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black87),
        ),
      ),
      home: const HomeScreen(),
      routes: {
        '/events': (context) => const EventListPage(),
        '/add-event': (context) => const AddEventPage(),
        '/calendar': (context) => const CalendarPage(),
      },
    );
  }
}
