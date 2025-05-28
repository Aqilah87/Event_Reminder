import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddEventPage extends StatefulWidget {
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDate;

  void _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _saveEvent() {
    if (_titleController.text.isNotEmpty && _selectedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd - kk:mm').format(_selectedDate!);
      Navigator.pop(context, {
        'title': _titleController.text,
        'date': formattedDate,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Add Event'),
        centerTitle: true,
        elevation: 0,
        ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Event Title'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickDateTime,
              child: Text(_selectedDate == null
                  ? 'Pick Date & Time'
                  : _selectedDate.toString()),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _saveEvent,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

