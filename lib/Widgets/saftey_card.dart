import 'package:flutter/material.dart';
import '../models/saftey_status.dart';

class SafetyCard extends StatelessWidget {
  final SafetyStatus status;

  const SafetyCard({super.key, required this.status});

  Color get color {
    switch (status.level) {
      case HazardLevel.safe:
        return Colors.green;
      case HazardLevel.caution:
        return Colors.orange;
      case HazardLevel.danger:
        return Colors.red;
    }
  }

  String get title {
    switch (status.level) {
      case HazardLevel.safe:
        return "SAFE";
      case HazardLevel.caution:
        return "CAUTION";
      case HazardLevel.danger:
        return "DANGER";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                )),
            const SizedBox(height: 8),
            Text(
              status.message,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
