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

  @HiveField(4)
  final String? imagePath;

  // ✅ NEW FIELDS: Store location coordinates
  @HiveField(5)
  final double? latitude;

  @HiveField(6)
  final double? longitude;

  Event({
    required this.title,
    required this.description,
    required this.dateTime,
    required this.reminderType,
    this.imagePath,
    this.latitude,
    this.longitude,
  });
}