import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'models/event.dart';
import 'models/user.dart';
import 'models/event_data.dart';
import 'models/auth_data.dart';
import 'screens/login_page.dart';
import 'screens/event_list_page.dart';
import 'screens/add_event_page.dart';
import 'screens/calendar_page.dart';
import 'screens/home_screen.dart';
import 'screens/settings_page.dart';
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocDir = await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);

  Hive.registerAdapter(EventAdapter());
  Hive.registerAdapter(UserAdapter());

  await Hive.openBox<Event>('events');
  await Hive.openBox<User>('users');
  await Hive.openBox('settings');

  final authData = AuthData();
  await authData.loadLoggedInUser();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthData()),
        ChangeNotifierProvider(create: (_) => EventData()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Event Reminder',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.deepPurple,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        cardColor: Colors.white,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF121212),
        primaryColor: Colors.tealAccent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardColor: Color(0xFF1E1E1E),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: Consumer<AuthData>(
        builder: (context, auth, _) {
          return auth.currentUser == null
              ? const LoginPage()
              : const HomeScreen();
        },
      ),
      routes: {
        '/events': (context) => const EventListPage(),
        '/add-event': (context) => const AddEventPage(),
        '/calendar': (context) => const CalendarPage(),
        '/settings': (context) => const SettingsPage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
