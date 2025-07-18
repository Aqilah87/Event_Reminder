import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/event.dart';
import '../widgets/in_app_noti.dart';

// Helper extensions for DateTime formatting (as discussed previously)
extension DateTimeFormatting on DateTime {
  String toShortDateString() {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/${year.toString()}';
  }

  String toShortTimeString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}

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
  XFile? _imageFile;
  String? _currentImagePath;
  int? _eventKey; // To store the event's Hive key

  final List<String> reminderTypes = [
    'Meeting',
    'Birthday',
    'Reminder',
    'Exam',
    'Other',
  ];

  final List<String> repeatOptions = [
    'None',
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly',
  ];

  // Define a consistent text style for form input/selection
  static const TextStyle _formTextStyle = TextStyle(
    fontSize: 16, // Consistent font size for inputs
    color: Colors.black, // Always black for input text
    // fontFamily: 'YourAppFont', // Uncomment and set if you have a custom font
  );

  // Define a consistent style for hint text
  static const TextStyle _hintTextStyle = TextStyle(
    fontSize: 16, // Same font size as input for alignment
    color: Colors.grey, // Grey for hints
    // fontFamily: 'YourAppFont',
  );

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _startDateTime = widget.event!.dateTime;
      _endDateTime = widget.event!.dateTime.add(const Duration(hours: 1));
      _reminderType = widget.event!.reminderType;
      _currentImagePath = widget.event!.imagePath;
      _eventKey = widget.event!.key; // ✅ Store the key of the event being edited
      print(
          'AddEventPage: Initialized for editing. Passed event: "${widget.event!.title}", Captured Key: $_eventKey');
      if (_eventKey == null) {
        print(
            'AddEventPage: WARNING: widget.event.key is null for an existing event. This might be the root cause.');
      }
    } else {
      print('AddEventPage: Initialized for adding new event (no key yet).');
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = image;
      print('AddEventPage: Image picked: ${_imageFile?.path}');
    });
  }

  Future<String?> _saveImageLocally(XFile image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = p.basename(image.path);
      final String newPath = p.join(directory.path, fileName);
      final File newImage = await File(image.path).copy(newPath);
      print('AddEventPage: Image saved locally to: $newPath');
      return newPath;
    } catch (e) {
      print('AddEventPage: Error saving image locally: $e');
      return null;
    }
  }

  void _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      if (_startDateTime == null || _endDateTime == null) {
        _showSnackBar('Please select both start and end date/time.');
        return;
      }

      if (_endDateTime!.isBefore(_startDateTime!)) {
        _showSnackBar('End time must be after start time.');
        return;
      }

      String? finalImagePath = _currentImagePath;

      if (_imageFile != null) {
        finalImagePath = await _saveImageLocally(_imageFile!);
        if (finalImagePath == null) {
          _showSnackBar('Failed to save image.');
          return;
        }
      }

  // 🧪 Debug logs — helps confirm saving date & behavior
      print("📅 Start DateTime: $_startDateTime");
      print("📅 End DateTime: $_endDateTime");

      // 🎉 Optional: Feedback if event is today
      final now = DateTime.now();
      if (_startDateTime!.day == now.day &&
          _startDateTime!.month == now.month &&
          _startDateTime!.year == now.year) {
        showNotification("🗓️ This event is happening today!");
      }

      final newEvent = Event(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dateTime: _startDateTime!,
        reminderType: _reminderType ?? 'Reminder',
        imagePath: finalImagePath,
      );

      _showSnackBar(
        widget.event == null
            ? 'Event saved successfully!'
            : 'Event updated successfully!',
        isError: false,
      );

      print('✅ Returning to HomeScreen. Title: "${newEvent.title}", Key: $_eventKey');
      Navigator.pop(context, {'event': newEvent, 'key': _eventKey});
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

  void showNotification(String message) {
    final overlay = Overlay.of(context);
    if (overlay == null) {
      print("⚠️ Overlay is null. Notification can't be shown.");
      return;
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          InAppNotification(
            message: message,
            onDismiss: () => entry.remove(),
          ),
        ],
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () => entry.remove());
  }


  @override
  Widget build(BuildContext context) {
    // Determine button text based on whether we are editing or adding
    final String buttonText =
        widget.event == null ? 'Save Event' : 'Update Event';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.event == null ? 'Add Event' : 'Edit Event',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            // fontFamily: 'YourAppFont', // Consistent font for app bar title
          ),
        ),
        backgroundColor: Colors.purple.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
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
                const SizedBox(height: 16),
                _buildLabel('🖼️ Event Image (Optional)'),
                Center(
                  child: Column(
                    children: [
                      if (_imageFile != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_imageFile!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else if (_currentImagePath != null &&
                          _currentImagePath!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_currentImagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.broken_image,
                                      size: 50, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                        )
                      else
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Center(
                            child:
                                Icon(Icons.image, size: 50, color: Colors.grey),
                          ),
                        ),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: Text('Add Image',
                            style: _formTextStyle.copyWith(
                                color: Colors
                                    .purple.shade700)), // Use consistent style
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade50,
                          foregroundColor: Colors.purple
                              .shade700, // This sets icon color implicitly
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      if (_imageFile != null ||
                          (_currentImagePath != null &&
                              _currentImagePath!.isNotEmpty))
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _imageFile = null;
                              _currentImagePath = null;
                            });
                          },
                          icon: Icon(Icons.clear, color: Colors.red.shade700),
                          label: Text('Remove Image',
                              style: _formTextStyle.copyWith(
                                  color: Colors
                                      .red.shade700)), // Use consistent style
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _saveEvent,
                    icon: const Icon(
                      Icons.save,
                      color: Colors.white,
                    ),
                    label: Text(
                      // ✅ Dynamic button text
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        // fontFamily: 'YourAppFont', // Consistent font for save button
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
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

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: _formTextStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white // White in dark mode
                : Colors.black,
          ),
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
      style: _formTextStyle, // Use the consistent text style
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: _hintTextStyle, // Use the consistent hint style
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
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.color, // Use theme's default for general button foreground
      ),
      child: Text(
        dateTime == null
            ? label
            : '${dateTime.toLocal().toShortDateString()} ${dateTime.toLocal().toShortTimeString()}',
        style: _formTextStyle.copyWith(
          color: dateTime == null
              ? Colors.purple.shade700 // Hint color for date/time picker
              : Colors.black, // Selected date/time color
        ),
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
      hint: Text(
        hint,
        style: _hintTextStyle, // Use consistent hint style
      ),
      dropdownColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[850]
          : Colors.white,
      items: options
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style:
                      _formTextStyle, // Use consistent text style for dropdown items
                ),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? validator : null,
      style:
          _formTextStyle, // Use consistent text style for the selected value in the field
    );
  }
}
