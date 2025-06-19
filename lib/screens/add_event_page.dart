import 'package:flutter/material.dart';
import '../models/event.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({Key? key, Event? event}) : super(key: key);

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();

  DateTime? _startDateTime;
  DateTime? _endDateTime;
  String? _reminderType;
  String? _repeatOption;

  final List<String> reminderTypes = ['Meeting', 'Birthday', 'Reminder', 'Anniversary'];
  final List<String> repeatOptions = ['None', 'Daily', 'Weekly', 'Monthly', 'Yearly'];

  Future<DateTime?> _pickDateTime({required bool isStart}) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      if (_startDateTime == null || _endDateTime == null) {
        _showSnackBar('Please select both start and end date/time.');
        return;
      }

      if (_endDateTime!.isBefore(_startDateTime!)) {
        _showSnackBar('End time must be after start time.');
        return;
      }

      final newEvent = Event(
        title: _titleController.text.trim(),
        date: _startDateTime!,
        reminderType: _reminderType,
        // You can extend Event model to include end time, type, repeat, etc.
      );

      _showSnackBar('Event saved successfully!', isError: false);
      Navigator.pop(context, newEvent);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color.fromARGB(255, 42, 134, 191);

    var _navigateToAddEvent;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text('Event Title', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter event title',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 16),

                // Start DateTime
                const Text('Start Date & Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () async {
                    final picked = await _pickDateTime(isStart: true);
                    if (picked != null) setState(() => _startDateTime = picked);
                  },
                  child: Text(_startDateTime == null
                      ? 'Pick Start Date & Time'
                      : _startDateTime.toString()),
                ),
                const SizedBox(height: 16),

                // End DateTime
                const Text('End Date & Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () async {
                    final picked = await _pickDateTime(isStart: false);
                    if (picked != null) setState(() => _endDateTime = picked);
                  },
                  child: Text(_endDateTime == null
                      ? 'Pick End Date & Time'
                      : _endDateTime.toString()),
                ),
                const SizedBox(height: 16),

                // Reminder Type Dropdown
                const Text('Reminder Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _reminderType,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: reminderTypes.map((type) =>
                    DropdownMenuItem(value: type, child: Text(type))
                  ).toList(),
                  onChanged: (value) => setState(() => _reminderType = value),
                  validator: (value) => value == null ? 'Please select a reminder type' : null,
                ),
                const SizedBox(height: 16),

                // Repeat Dropdown
                const Text('Repeat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _repeatOption,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: repeatOptions.map((option) =>
                    DropdownMenuItem(value: option, child: Text(option))
                  ).toList(),
                  onChanged: (value) => setState(() => _repeatOption = value),
                  validator: (value) => value == null ? 'Please select repeat option' : null,
                ),
                const SizedBox(height: 32),

                // Save Button
                Center(
                  child: ElevatedButton(
                    onPressed: _saveEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Event', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
       floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddEvent,
        child: Icon(Icons.add),
      ),
    );
  }
}
