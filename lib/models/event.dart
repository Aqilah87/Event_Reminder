// TODO Implement this library.// lib/models/event.dart

/// Model class representing a reminder event.
class Event {
  /// Title or description of the event.
  final String title;

  /// Date for the event (date portion only, time is ignored).
  final DateTime date;
  String? reminderType;

  /// Creates an Event with the given [title] and [date].
  Event({
    required this.title,
    required this.date,
    this.reminderType
  });
}