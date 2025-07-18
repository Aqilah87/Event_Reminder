import 'package:flutter/material.dart';
import '../models/category.dart';

const List<Category> categoryList = [
  Category(name: 'Meeting', color: Colors.blue, icon: Icons.business),
  Category(name: 'Reminder', color: Colors.green, icon: Icons.alarm),
  Category(name: 'Birthday', color: Colors.yellow, icon: Icons.cake),
  Category(name: 'Exam', color: Color.fromARGB(255, 244, 108, 54), icon: Icons.schedule),
];