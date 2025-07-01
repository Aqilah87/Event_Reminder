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
    _events.addAll(box.values);
    notifyListeners();
  }

  Future<void> addEvent(Event event) async {
    final box = Hive.box<Event>('events');
    await box.add(event);
    _events.add(event);
    notifyListeners();
  }

  Future<void> deleteEvent(Event event) async {
    final box = Hive.box<Event>('events');

    // Find key of the event to delete it from the box
    final key =
        box.keys.firstWhere((k) => box.get(k) == event, orElse: () => null);
    if (key != null) {
      await box.delete(key);
      _events.remove(event);
      notifyListeners();
    }
  }

  Future<void> updateEvent(Event oldEvent, Event newEvent) async {
    final box = Hive.box<Event>('events');
    final key =
        box.keys.firstWhere((k) => box.get(k) == oldEvent, orElse: () => null);
    if (key != null) {
      await box.put(key, newEvent);
      final index = _events.indexOf(oldEvent);
      if (index != -1) {
        _events[index] = newEvent;
        notifyListeners();
      }
    }
  }
}
