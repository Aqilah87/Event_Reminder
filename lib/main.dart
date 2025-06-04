import 'package:flutter/material.dart';
import 'package:reminder_test/home_screen.dart';
import 'package:reminder_test/database/db_helper.dart';
import 'package:reminder_test/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database and notifications
  await DbHelper.initDb();
  await NotificationHelper.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
