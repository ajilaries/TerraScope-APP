import '../models/saftey_status.dart';

class SafetyService {
  static SafetyStatus checkSafety({
    required double rainMm,
    required double windSpeed,
    required int visibility,
  }) {
    if (rainMm > 50 || windSpeed > 40 || visibility < 200) {
      return SafetyStatus(
        level: HazardLevel.danger,
        message: "Dangerous weather conditions detected",
        time: DateTime.now(),
      );
    }

    if (rainMm > 10 || windSpeed > 20 || visibility < 500) {
      return SafetyStatus(
        level: HazardLevel.caution,
        message: "Weather conditions require caution",
        time: DateTime.now(),
      );
    }

    return SafetyStatus(
      level: HazardLevel.safe,
      message: "Weather is safe",
      time: DateTime.now(),
    );
  }
}
