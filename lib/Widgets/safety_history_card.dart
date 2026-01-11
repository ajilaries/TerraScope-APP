import 'package:flutter/material.dart';
import '../models/safety_alert.dart';
import '../utils/safety_utils.dart';

class SafetyHistoryCard extends StatelessWidget {
  final SafetyAlert alert;

  const SafetyHistoryCard({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    final color = SafetyUtils.getColorForLevel(alert.level);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with time and level
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          SafetyUtils.getTextForLevel(alert.level),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          alert.message.length > 40
                              ? '${alert.message.substring(0, 40)}...'
                              : alert.message,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        SafetyUtils.getTimeAgo(alert.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${alert.temperature.toStringAsFixed(0)}°C',
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Weather parameters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _HistoryParamBadge(
                      icon: '🌧️',
                      label: 'Rain',
                      value: '${alert.rainMm.toStringAsFixed(1)}mm',
                    ),
                    const SizedBox(width: 8),
                    _HistoryParamBadge(
                      icon: '💨',
                      label: 'Wind',
                      value: '${alert.windSpeed.toStringAsFixed(0)}km/h',
                    ),
                    const SizedBox(width: 8),
                    _HistoryParamBadge(
                      icon: '👁️',
                      label: 'Visibility',
                      value: '${alert.visibility}m',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryParamBadge extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _HistoryParamBadge({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
