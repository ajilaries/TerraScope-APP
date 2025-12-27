import '../models/saftey_status.dart';

class SafetyAlert {
  final HazardLevel level;
  final String message;
  final DateTime timestamp;
  final double rainMm;
  final double windSpeed;
  final int visibility;
  final double temperature;

  SafetyAlert({
    required this.level,
    required this.message,
    required this.timestamp,
    required this.rainMm,
    required this.windSpeed,
    required this.visibility,
    required this.temperature,
  });
}
