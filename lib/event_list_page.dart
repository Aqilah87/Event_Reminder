import 'package:flutter/material.dart';
import 'add_event_page.dart';

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Map<String, String>> events = [];

  void addEvent(String title, String dateTime) {
    setState(() {
      events.add({'title': title, 'date': dateTime});
    });
  }

  void deleteEvent(int index) {
    setState(() {
      events.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFCE93D8),
        title: Text('My Events'),
      centerTitle: true,
      ),

            body: events.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 250, // Adjust as needed
                    height: 250,
                    child: Image.asset(
                      'assets/logo_reminder-removebg-preview.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Your Day, Perfectly Planned",
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "No events yet. Add some!",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )



          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(events[index]['title']!),
                  subtitle: Text(events[index]['date']!),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deleteEvent(index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEventPage()),
          );
          if (result != null) {
            addEvent(result['title'], result['date']);
          }
        },
      ),
    );
  }
  }