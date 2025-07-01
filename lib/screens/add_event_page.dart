import 'package:flutter/material.dart';
import '../models/event.dart';

class AddEventPage extends StatefulWidget {
  final Event? event;

  const AddEventPage({Key? key, this.event}) : super(key: key);

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _startDateTime;
  DateTime? _endDateTime;
  String? _reminderType;
  String? _repeatOption;

  final List<String> reminderTypes = [
    'Meeting',
    'Birthday',
    'Reminder',
    'Anniversary',
    'Other', // ✅ Added
  ];

  final List<String> repeatOptions = [
    'None',
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _startDateTime = widget.event!.dateTime;
      _endDateTime = widget.event!.dateTime.add(const Duration(hours: 1));
      _reminderType = widget.event!.reminderType;
    }
  }

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
        description: _descriptionController.text.trim(),
        dateTime: _startDateTime!,
        reminderType: _reminderType ?? 'Reminder',
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
    const primaryColor = Color.fromARGB(255, 42, 134, 191);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.event == null ? 'Add Event' : 'Edit Event',
          style: const TextStyle(
            color: Colors.white, // Change title text color here
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple.shade700,
        iconTheme: const IconThemeData(
            color: Colors.white), // Optional: makes back icon white
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('📝 Event Title'),
                _buildTextField(
                  controller: _titleController,
                  hintText: 'e.g. Doctor Appointment',
                  validatorMsg: 'Please enter a title',
                ),
                const SizedBox(height: 16),
                _buildLabel('🗒️ Description (Optional)'),
                _buildTextField(
                  controller: _descriptionController,
                  hintText: 'Write additional notes or location...',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildLabel('🕒 Start Date & Time'),
                _buildDateButton(
                  dateTime: _startDateTime,
                  label: 'Pick Start Date & Time',
                  onTap: () async {
                    final picked = await _pickDateTime(isStart: true);
                    if (picked != null) setState(() => _startDateTime = picked);
                  },
                ),
                const SizedBox(height: 16),
                _buildLabel('⏰ End Date & Time'),
                _buildDateButton(
                  dateTime: _endDateTime,
                  label: 'Pick End Date & Time',
                  onTap: () async {
                    final picked = await _pickDateTime(isStart: false);
                    if (picked != null) setState(() => _endDateTime = picked);
                  },
                ),
                const SizedBox(height: 16),
                _buildLabel('📌 Reminder Type'),
                _buildDropdown(
                  value: _reminderType,
                  hint: 'Select reminder category',
                  options: reminderTypes,
                  onChanged: (value) => setState(() => _reminderType = value),
                  validator: 'Please select a reminder type',
                ),
                const SizedBox(height: 16),
                _buildLabel('🔁 Repeat'),
                _buildDropdown(
                  value: _repeatOption,
                  hint: 'Set repeat schedule (if any)',
                  options: repeatOptions,
                  onChanged: (value) => setState(() => _repeatOption = value),
                  validator: 'Please select repeat option',
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _saveEvent,
                    icon: const Icon(
                      Icons.save,
                      color: Colors.white, // ✅ Icon color
                    ),
                    label: const Text(
                      'Save Event',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // ✅ Text color
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.purple.shade700, // ✅ Soft blue background
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widgets Below
  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? validatorMsg,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
      ),
      validator: validatorMsg == null
          ? null
          : (value) => value == null || value.isEmpty ? validatorMsg : null,
    );
  }

  Widget _buildDateButton({
    required DateTime? dateTime,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      child: Text(
        dateTime == null ? label : dateTime.toString(),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required String validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      hint: Text(hint),
      items: options
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? validator : null,
    );
  }
}
