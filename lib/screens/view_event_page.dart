import 'package:flutter/material.dart';
import '../models/event.dart';
import 'dart:io';

class ViewEventPage extends StatelessWidget {
  final Event event;

  const ViewEventPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = "${event.dateTime.day.toString().padLeft(2, '0')}/${event.dateTime.month.toString().padLeft(2, '0')}/${event.dateTime.year}";
    final formattedTime = "${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Details"),
        backgroundColor: Colors.purple.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "📝 ${event.title}",
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18, color: Colors.purple),
                    const SizedBox(width: 8),
                    Text("📅 $formattedDate"),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18, color: Colors.purple),
                    const SizedBox(width: 8),
                    Text("⏰ $formattedTime"),
                  ],
                ),
                const SizedBox(height: 16),

                if (event.description != null && event.description!.isNotEmpty) ...[
                  Text("🗒️ Notes", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(event.description!, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                ],

                if (event.imagePath != null && event.imagePath!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(event.imagePath!),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text("⚠️ Unable to load image.");
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
