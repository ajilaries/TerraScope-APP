import 'package:flutter/material.dart';

class CommuteAlerts extends StatelessWidget {
  final List<CommuteAlert> alerts;

  const CommuteAlerts({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Alerts",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        // If no alerts found
        if (alerts.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "No active commute alerts 🎉",
              style: TextStyle(fontSize: 16),
            ),
          ),

        // List of alerts
        ...alerts.map((alert) => _buildAlertCard(alert)),
      ],
    );
  }

  Widget _buildAlertCard(CommuteAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _alertColor(alert.type),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _alertIcon(alert.type),
            size: 28,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  alert.time,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Color _alertColor(AlertType type) {
    switch (type) {
      case AlertType.weather:
        return Colors.blueAccent;
      case AlertType.traffic:
        return Colors.orangeAccent;
      case AlertType.safety:
        return Colors.redAccent;
      }
  }

  IconData _alertIcon(AlertType type) {
    switch (type) {
      case AlertType.weather:
        return Icons.cloud;
      case AlertType.traffic:
        return Icons.traffic;
      case AlertType.safety:
        return Icons.warning_amber;
      }
  }
}

class CommuteAlert {
  final String title;
  final String description;
  final String time;
  final AlertType type;

  CommuteAlert({
    required this.title,
    required this.description,
    required this.time,
    required this.type,
  });
}

enum AlertType { weather, traffic, safety }
