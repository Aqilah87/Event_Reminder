import 'package:flutter/material.dart';
import 'package:reminder_test/screens/home_screen.dart';
import 'package:reminder_test/database/db_helper.dart';
import 'package:reminder_test/services/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database and notifications
  await DbHelper.initDb();
  await NotificationHelper.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Reminder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: HomeScreen(),
    );
  }
}