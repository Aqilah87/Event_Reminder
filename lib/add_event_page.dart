import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reminder_test/database/db_helper.dart';
import 'package:reminder_test/home_screen.dart';
import 'package:reminder_test/notification_helper.dart'; // Make sure this exists

class AddEventPage extends StatefulWidget {
  final int? reminderId;
  const AddEventPage({super.key, this.reminderId});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _categoryt = "Work";
  DateTime _reminderTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.reminderId != null) {
      fetchreminder();
    }
  }

  Future<void> fetchreminder() async {
    try {
      final data = await DbHelper.getRemindersById(widget.reminderId!);
      if (data != null) {
        setState(() {
          _titleController.text = data['title'];
          _descriptionController.text = data['description'];
          _reminderTime = DateTime.parse(data['reminder_time']);
          _categoryt = data['category'];
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text(widget.reminderId == null ? "Add Event" : "Edit Event",
            style: TextStyle(color: Colors.black, fontSize: 20)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildInputCard(
                  label: "Title",
                  icon: Icons.title,
                  child: TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter event title',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a title";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                buildInputCard(
                  label: "Description",
                  icon: Icons.description,
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter description',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a description";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                buildInputCard(
                  label: "Category",
                  icon: Icons.category,
                  child: DropdownButtonFormField<String>(
                    value: _categoryt,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select category',
                    ),
                    items: <String>['Work', 'Personal', 'Shopping', 'Health', 'Others']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _categoryt = newValue!;
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),
                buildDateTimePicker(
                  label: "Date",
                  icon: Icons.calendar_today,
                  displayValue: DateFormat('yyyy-MM-dd').format(_reminderTime),
                  onPressed: _selectDate,
                ),
                SizedBox(height: 10),
                buildDateTimePicker(
                  label: "Time",
                  icon: Icons.access_time,
                  displayValue: DateFormat('hh:mm a').format(_reminderTime),
                  onPressed: _selectTime,
                ),
                SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _saveReminder,
                    child: Text("Save Reminder"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputCard({required String label, required IconData icon, required Widget child}) {
    return Card(
      elevation: 6,
      color: Colors.teal.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.teal),
                SizedBox(width: 10),
                Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget buildDateTimePicker({
    required String label,
    required IconData icon,
    required String displayValue,
    required Function() onPressed,
  }) {
    return Card(
      elevation: 6,
      color: Colors.teal.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(displayValue.isEmpty ? 'Select Date & Time' : displayValue),
        trailing: TextButton(
          onPressed: onPressed,
          child: Text(displayValue, style: TextStyle(color: Colors.teal)),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _reminderTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _reminderTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _reminderTime.hour,
          _reminderTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      ),
    );
    if (picked != null) {
      setState(() {
        _reminderTime = DateTime(
          _reminderTime.year,
          _reminderTime.month,
          _reminderTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _saveReminder() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    final reminderData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'date': DateFormat('yyyy-MM-dd').format(_reminderTime),
      'category': _categoryt,
      'reminder_time': DateFormat('yyyy-MM-dd - kk:mm').format(_reminderTime),
    };
    if (widget.reminderId != null) {
      await DbHelper.updateReminders(widget.reminderId!, reminderData);
      NotificationHelper.scheduleNotification(
        _titleController.text, _categoryt, _reminderTime
      );
    } else {
      await DbHelper.addReminders(reminderData);
      NotificationHelper.scheduleNotification(
        _titleController.text, _categoryt, _reminderTime
      );
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }
}