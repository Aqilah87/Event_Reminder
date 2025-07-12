import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'event.dart';

class EventData extends ChangeNotifier {
  final List<Event> _events = [];

  EventData() {
    _loadEvents();
  }

  List<Event> get events => _events;

  List<Event> getAllEvents() => _events;

  List<Event> getTodayEvents() {
    final now = DateTime.now();
    return _events.where((event) =>
      event.dateTime.year == now.year &&
      event.dateTime.month == now.month &&
      event.dateTime.day == now.day).toList();
  }

  // ✅ Add this below
  List<Event> getEventsForDay(DateTime day) {
    return _events.where((event) =>
      event.dateTime.year == day.year &&
      event.dateTime.month == day.month &&
      event.dateTime.day == day.day).toList();
  }

  Future<void> _loadEvents() async {
    final box = Hive.box<Event>('events');
    _events.clear();
    // Ensure we add actual HiveObjects to the list so their .key property is available
    _events.addAll(box.values.cast<Event>());
    print('EventData: Initial load completed. Found ${_events.length} events.');
    for (var event in _events) {
      print('EventData: Loaded event: "${event.title}", Key: ${event.key}');
    }
    notifyListeners();
  }

  Future<void> addEvent(Event event) async {
    final box = Hive.box<Event>('events');
    print('EventData: Attempting to add new event: "${event.title}"');
    final key = await box.add(event); // Add returns the key
    // Re-fetch the event from the box to ensure the in-memory object
    // has the key assigned by Hive. This is crucial for subsequent updates/deletions.
    final eventWithKey = box.get(key);
    if (eventWithKey != null) {
      _events.add(eventWithKey);
      print(
          'EventData: Successfully added new event: "${eventWithKey.title}" with key: ${eventWithKey.key}. Total events: ${_events.length}');
    } else {
      print(
          'EventData: ERROR: Failed to retrieve event with key $key after adding. Adding original event object as fallback.');
      _events
          .add(event); // Fallback, but might not have a key if not re-fetched
    }
    notifyListeners();
  }

  Future<void> deleteEvent(Event event) async {
    final box = Hive.box<Event>('events');
    if (event.key != null) {
      print(
          'EventData: Attempting to delete event "${event.title}" with key: ${event.key}');
      await box.delete(event.key);
      _events.removeWhere(
          (e) => e.key == event.key); // Remove by key from in-memory list
      print(
          'EventData: Successfully deleted event with key: ${event.key}. Remaining events: ${_events.length}');
      notifyListeners();
    } else {
      print(
          "EventData: WARNING: Attempted to delete an event without a Hive key. Event title: ${event.title}. Deletion skipped from Hive, attempting in-memory removal.");
      final index = _events.indexOf(event);
      if (index != -1) {
        _events.removeAt(index);
        notifyListeners();
        print(
            'EventData: In-memory deletion successful for event without key.');
      } else {
        print('EventData: Event not found in-memory for deletion (no key).');
      }
    }
  }

  Future<void> updateEvent(int oldEventKey, Event newEvent) async {
    final box = Hive.box<Event>('events');
    print('EventData: --- Starting updateEvent ---');
    print('EventData: oldEventKey received: $oldEventKey');
    print(
        'EventData: New event details provided: Title: "${newEvent.title}", Description: "${newEvent.description}", ReminderType: "${newEvent.reminderType}", ImagePath: "${newEvent.imagePath}"');

    // Perform the update in Hive using put(key, object)
    // This will overwrite the existing entry at oldEventKey with newEvent's data.
    await box.put(oldEventKey, newEvent);
    print('EventData: Hive box.put($oldEventKey, newEvent) completed.');

    // ✅ CRITICAL FIX: After updating in Hive, reload all events to ensure in-memory list is in sync.
    // This guarantees that the _events list accurately reflects the database.
    await _loadEvents(); 

    print('EventData: notifyListeners() called. --- updateEvent Finished ---');
  }
}
