enum HazardLevel { safe, caution, danger }

class SafetyStatus {
  final HazardLevel level;
  final String message;
  final DateTime time;
  final int riskScore;
  final List<String> warnings;

  SafetyStatus({
    required this.level,
    required this.message,
    required this.time,
    this.riskScore = 0,
    this.warnings = const [],
  });

  // Get emoji representation
  String get emoji {
    switch (level) {
      case HazardLevel.safe:
        return '✅';
      case HazardLevel.caution:
        return '⚠️';
      case HazardLevel.danger:
        return '🚨';
    }
  }

  // Get color representation
  String get colorName {
    switch (level) {
      case HazardLevel.safe:
        return 'Green';
      case HazardLevel.caution:
        return 'Orange';
      case HazardLevel.danger:
        return 'Red';
    }
  }
}
