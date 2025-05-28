import 'package:flutter/material.dart';
import 'event_list_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Reminder',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: EventListPage(),
    );
  }
}
