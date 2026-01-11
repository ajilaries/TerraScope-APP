import 'package:flutter/material.dart';
import '../models/saftey_status.dart';
import '../utils/safety_utils.dart';

class DetailedSafetyCard extends StatelessWidget {
  final SafetyStatus status;
  final double rainMm;
  final double windSpeed;
  final int visibility;
  final double temperature;
  final int humidity;

  const DetailedSafetyCard({
    super.key,
    required this.status,
    required this.rainMm,
    required this.windSpeed,
    required this.visibility,
    required this.temperature,
    required this.humidity,
  });

  @override
  Widget build(BuildContext context) {
    final color = SafetyUtils.getColorForLevel(status.level);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  Icon(
                    status.level == HazardLevel.safe
                        ? Icons.check_circle
                        : status.level == HazardLevel.caution
                            ? Icons.warning
                            : Icons.dangerous,
                    color: color,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          SafetyUtils.getTextForLevel(status.level),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          'Risk Score: ${status.riskScore}/100',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Weather parameters grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _WeatherParamTile(
                    icon: Icons.cloud_queue,
                    label: 'Rainfall',
                    value: '${rainMm.toStringAsFixed(1)} mm',
                    color: Colors.blue,
                  ),
                  _WeatherParamTile(
                    icon: Icons.air,
                    label: 'Wind Speed',
                    value: '${windSpeed.toStringAsFixed(1)} km/h',
                    color: Colors.cyan,
                  ),
                  _WeatherParamTile(
                    icon: Icons.visibility,
                    label: 'Visibility',
                    value: '$visibility m',
                    color: Colors.purple,
                  ),
                  _WeatherParamTile(
                    icon: Icons.thermostat,
                    label: 'Temperature',
                    value: '${temperature.toStringAsFixed(1)}°C',
                    color: Colors.red,
                  ),
                  _WeatherParamTile(
                    icon: Icons.opacity,
                    label: 'Humidity',
                    value: '$humidity%',
                    color: Colors.teal,
                  ),
                  _WeatherParamTile(
                    icon: Icons.info,
                    label: 'Description',
                    value: SafetyUtils.getWindDescription(windSpeed),
                    color: Colors.amber,
                  ),
                ],
              ),

              if (status.warnings.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Warnings:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...status.warnings.map(
                  (warning) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: color, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            warning,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),
              Text(
                'Updated: ${SafetyUtils.getTimeAgo(status.time)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherParamTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _WeatherParamTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
