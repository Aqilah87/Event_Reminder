import 'package:flutter/foundation.dart';
import 'event.dart';

class EventData extends ChangeNotifier {
  final List<Event> _events = [];

  List<Event> getAllEvents() => _events;

  List<Event> getEventsForDay(DateTime day) {
    return _events.where((event) =>
        event.date.year == day.year &&
        event.date.month == day.month &&
        event.date.day == day.day).toList();
  }

  void addEvent(Event event) {
    _events.add(event);
    notifyListeners();
  }

  void deleteEvent(Event event) {
    _events.remove(event);
    notifyListeners();
  }

  // ✅ This is what you’re missing: updateEvent method
  void updateEvent(Event oldEvent, Event newEvent) {
    final index = _events.indexOf(oldEvent);
    if (index != -1) {
      _events[index] = newEvent;
      notifyListeners();
    }
  }
}

