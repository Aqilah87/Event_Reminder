import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event.dart';
import '../models/event_data.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Event> _getEventsForDay(DateTime day, EventData eventData) {
    return eventData.getEventsForDay(day);
  }

  @override
  Widget build(BuildContext context) {
    final eventData = Provider.of<EventData>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 42, 134, 191),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TableCalendar<Event>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) => _getEventsForDay(day, eventData),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black87),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black87),
              ),
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.black87,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(color: Colors.redAccent),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _getEventsForDay(_selectedDay!, eventData).isEmpty
                  ? const Center(
                      child: Text(
                        'No events for this day.',
                        style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _getEventsForDay(_selectedDay!, eventData).length,
                      itemBuilder: (context, index) {
                        final event = _getEventsForDay(_selectedDay!, eventData)[index];
                        return ListTile(
                          leading: const Icon(Icons.event_note, color: Colors.black87),
                          title: Text(
                            event.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(event.reminderType ?? 'General'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
