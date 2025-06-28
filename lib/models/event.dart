import 'package:hive/hive.dart';

part 'event.g.dart';

@HiveType(typeId: 0)
class Event extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final DateTime dateTime;

  @HiveField(3)
  final String reminderType;

Event({
    required this.title,
    required this.description,
    required this.dateTime,
    required this.reminderType, 
  });
}
