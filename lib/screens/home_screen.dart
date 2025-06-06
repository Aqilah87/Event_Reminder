import 'package:flutter/material.dart';
import 'package:reminder_test/screens/add_event_page.dart';
import 'event_list_page.dart';

class HomeScreen extends StatelessWidget{
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 42, 134, 191),
        title: Text('Home Screen'),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu), 
            onPressed: () => Scaffold.of(context).openDrawer()
            ),
        ),

        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEventPage()),
              );
            },
          ),
        ],
      ),

      //sidebar menu
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Color.fromARGB(255, 42, 134, 191)),
            child: Text(
              'Menu',
            style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),

          ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.event),
              title: Text('Events'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventListPage()),
                );
              },
            ),
          ],
            ),
          ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
            width: 100,
            height: 100,
            color: Colors.greenAccent[300],
            child: Center(
              child: Text ('Add Your Event Now'),
            ),
            ),
          ],
        ),
        ),
      );
  }
}