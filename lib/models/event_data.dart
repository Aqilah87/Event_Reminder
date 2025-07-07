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

  List<Event> getEventsForDay(DateTime day) {
    return _events
        .where((event) =>
            event.dateTime.year == day.year &&
            event.dateTime.month == day.month &&
            event.dateTime.day == day.day)
        .toList();
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

    // Verify if the old key exists in the box before updating
    final existingEventInBox = box.get(oldEventKey);
    if (existingEventInBox == null) {
      print(
          'EventData: ERROR: No existing event found in Hive box with key: $oldEventKey. Cannot update. This might lead to duplicates if newEvent is added later.');
      notifyListeners();
      return;
    }
    print(
        'EventData: Found existing event in Hive box with key $oldEventKey. Its current title: "${existingEventInBox.title}"');

    // Perform the update in Hive using put(key, object)
    await box.put(oldEventKey, newEvent);
    print('EventData: Hive box.put($oldEventKey, newEvent) completed.');

    // ✅ CRITICAL FIX: Re-fetch the updated event from the box to ensure the in-memory object
    // has the correct Hive key and is the exact Hive-managed instance.
    final updatedEventFromBox = box.get(oldEventKey);

    // Update the in-memory list
    final index = _events.indexWhere((event) => event.key == oldEventKey);
    if (index != -1) {
      print(
          'EventData: Found in-memory event at index $index for key $oldEventKey. Old in-memory title: "${_events[index].title}"');
      if (updatedEventFromBox != null) {
        _events[index] =
            updatedEventFromBox; // Use the object fetched from Hive
        print(
            'EventData: In-memory list updated successfully at index $index. New in-memory title: "${_events[index].title}"');
      } else {
        // This case should ideally not happen if box.put was successful
        print(
            'EventData: WARNING: Failed to retrieve updated event from box after put. Falling back to newEvent object for in-memory update.');
        _events[index] =
            newEvent; // Fallback to using the passed newEvent object
      }
    } else {
      print(
          'EventData: WARNING: Event with key $oldEventKey NOT found in in-memory list. This indicates a sync issue. Adding the updated event as a new entry.');
      // If not found, add it. This is a fallback for out-of-sync scenarios.
      if (updatedEventFromBox != null) {
        _events.add(updatedEventFromBox);
      } else {
        _events.add(newEvent);
      }
    }
    notifyListeners();
    print('EventData: notifyListeners() called. --- updateEvent Finished ---');
  }
}
