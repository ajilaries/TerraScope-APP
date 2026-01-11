import 'package:flutter/material.dart';

class SafetyNotificationManager {
  /// Show alert notification
  static void showSafetyAlert(
    BuildContext context, {
    required String title,
    required String message,
    required Color color,
    IconData icon = Icons.warning,
    Duration duration = const Duration(seconds: 5),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Show emergency alert dialog
  static void showEmergencyAlert(
    BuildContext context, {
    required String title,
    required String message,
    required List<String> warnings,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.dangerous, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 16),
              if (warnings.isNotEmpty) ...[
                const Text(
                  'Issues Detected:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...warnings.map(
                  (warning) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.error, size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(warning,
                              style: const TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show success notification
  static void showSuccess(BuildContext context, String message) {
    showSafetyAlert(
      context,
      title: 'Success',
      message: message,
      color: Colors.green,
      icon: Icons.check_circle,
    );
  }

  /// Show warning notification
  static void showWarning(BuildContext context, String message) {
    showSafetyAlert(
      context,
      title: 'Warning',
      message: message,
      color: Colors.orange,
      icon: Icons.warning,
    );
  }

  /// Show error notification
  static void showError(BuildContext context, String message) {
    showSafetyAlert(
      context,
      title: 'Error',
      message: message,
      color: Colors.red,
      icon: Icons.error,
    );
  }

  /// Show info notification
  static void showInfo(BuildContext context, String message) {
    showSafetyAlert(
      context,
      title: 'Information',
      message: message,
      color: Colors.blue,
      icon: Icons.info,
    );
  }
}
