import 'package:flutter/material.dart';
import '../models/saftey_status.dart';

class SafetyUtils {
  // Get color based on hazard level
  static Color getColorForLevel(HazardLevel level) {
    switch (level) {
      case HazardLevel.safe:
        return Colors.green;
      case HazardLevel.caution:
        return Colors.orange;
      case HazardLevel.danger:
        return Colors.red;
    }
  }

  // Get dark color for level
  static Color getDarkColorForLevel(HazardLevel level) {
    switch (level) {
      case HazardLevel.safe:
        return Colors.green.shade700;
      case HazardLevel.caution:
        return Colors.orange.shade700;
      case HazardLevel.danger:
        return Colors.red.shade700;
    }
  }

  // Get text for level
  static String getTextForLevel(HazardLevel level) {
    switch (level) {
      case HazardLevel.safe:
        return 'SAFE';
      case HazardLevel.caution:
        return 'CAUTION';
      case HazardLevel.danger:
        return 'DANGER';
    }
  }

  // Format time ago
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  // Format wind speed
  static String formatWindSpeed(double speed) {
    return '${speed.toStringAsFixed(1)} km/h';
  }

  // Format rainfall
  static String formatRainfall(double mm) {
    return '${mm.toStringAsFixed(1)} mm';
  }

  // Get wind description
  static String getWindDescription(double speed) {
    if (speed < 5) return 'Calm';
    if (speed < 15) return 'Light breeze';
    if (speed < 30) return 'Moderate wind';
    if (speed < 40) return 'Strong wind';
    if (speed < 50) return 'Very strong wind';
    return 'Extreme wind';
  }

  // Get visibility description
  static String getVisibilityDescription(int visibility) {
    if (visibility > 10000) return 'Excellent';
    if (visibility > 5000) return 'Good';
    if (visibility > 1000) return 'Moderate';
    if (visibility > 500) return 'Poor';
    return 'Very poor';
  }
}
