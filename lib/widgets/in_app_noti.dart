import 'package:flutter/material.dart';

class InAppNotification extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const InAppNotification({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        color: Colors.blueAccent,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(child: Text(message, style: TextStyle(color: Colors.white))),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: onDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
