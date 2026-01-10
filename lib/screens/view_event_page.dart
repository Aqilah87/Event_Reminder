import 'package:flutter/material.dart';
import '../models/event.dart';
import 'dart:io';
import 'package:latlong2/latlong.dart'; // ✅ Needed for LatLng
import 'map_page.dart'; // ✅ Needed to navigate to MapPage

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
        backgroundColor: Colors.purple.shade700,
        title: const Text(
          "Event Details",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
                // Title
                Text(
                  event.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800,
                  ),
                ),
                const Divider(height: 30),

                // Date & Time
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
                
                // Category
                Row(
                  children: [
                    const Icon(Icons.label, size: 18, color: Colors.purple),
                    const SizedBox(width: 8),
                    Text("Category: ${event.reminderType}"),
                  ],
                ),
                const SizedBox(height: 16),

                // ✅ LOCATION SECTION
                if (event.latitude != null && event.longitude != null) ...[
                   Row(
                    children: [
                      const Icon(Icons.location_pin, size: 18, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Location: ${event.latitude!.toStringAsFixed(5)}, ${event.longitude!.toStringAsFixed(5)}",
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // ✅ Button to Open Map
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapPage(
                              initialLocation: LatLng(event.latitude!, event.longitude!),
                              isSelecting: false, // ✅ Set View Only Mode
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.map, color: Colors.white),
                      label: const Text("View on Map"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Description
                if (event.description.isNotEmpty) ...[
                  Text("🗒️ Notes", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(event.description, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                ],

                // Image
                if (event.imagePath != null && event.imagePath!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(event.imagePath!),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Center(child: Text("⚠️ Unable to load image.")),
                        );
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