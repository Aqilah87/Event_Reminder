import 'package:flutter/material.dart';
import 'event_list_page.dart';

class HomeScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        actions: [

          //icon
          IconButton(
            icon: Icon(Icons.search),
            onPressed: (){
            },
            ),
            IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
            },
          ),
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
            width: 100,
            height: 100,
            color: Colors.greenAccent[300],
            child: Center(child: Text ('Your List')),
            ),
          ],
        ),
        ),
      );
  }
}