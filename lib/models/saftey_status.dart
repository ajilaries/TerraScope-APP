enum HazardLevel { safe, caution, danger }

class SafetyStatus {
  final HazardLevel level;
  final String message;
  final DateTime time;

  SafetyStatus({
    required this.level,
    required this.message,
    required this.time,
  });
}