import 'package:flutter/material.dart';
import 'home_screen.dart';

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}
class _EventListPageState extends State<EventListPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFCE93D8),
        title: Text('My Events'),
      centerTitle: true,
      ),

            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: (){
                print("Div clicked!");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder:(context) => HomeScreen()),
                  );
              },

              child: Center(
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
                    "Your Day, Perfectly Plannned",
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "No events yet.",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ),
    );
    }
    }