import '../models/saftey_status.dart';

class SafetyService {
  // Comprehensive safety check with multiple parameters
  static SafetyStatus checkSafety({
    required double rainMm,
    required double windSpeed,
    required int visibility,
    double temperature = 25,
    int humidity = 60,
  }) {
    // Calculate risk factors
    double riskScore = 0;
    List<String> warnings = [];

    // Rain assessment
    if (rainMm > 50) {
      riskScore += 40;
      warnings.add('Heavy rainfall (${rainMm.toStringAsFixed(1)}mm)');
    } else if (rainMm > 10) {
      riskScore += 15;
      warnings.add('Moderate rainfall (${rainMm.toStringAsFixed(1)}mm)');
    }

    // Wind assessment
    if (windSpeed > 40) {
      riskScore += 40;
      warnings.add('Extreme wind (${windSpeed.toStringAsFixed(1)} km/h)');
    } else if (windSpeed > 20) {
      riskScore += 15;
      warnings.add('Strong wind (${windSpeed.toStringAsFixed(1)} km/h)');
    }

    // Visibility assessment
    if (visibility < 200) {
      riskScore += 40;
      warnings.add('Very poor visibility ($visibility m)');
    } else if (visibility < 500) {
      riskScore += 20;
      warnings.add('Poor visibility ($visibility m)');
    }

    // Temperature assessment
    if (temperature > 45 || temperature < -10) {
      riskScore += 20;
      warnings.add('Extreme temperature (${temperature.toStringAsFixed(1)}°C)');
    } else if (temperature > 40 || temperature < 0) {
      riskScore += 10;
      warnings.add('Harsh temperature (${temperature.toStringAsFixed(1)}°C)');
    }

    // Humidity assessment
    if (humidity > 90) {
      riskScore += 10;
      warnings.add('Very high humidity ($humidity%)');
    }

    // Determine hazard level
    HazardLevel level;
    String message;

    if (riskScore >= 60) {
      level = HazardLevel.danger;
      message = 'DANGER: ${warnings.join(', ')}';
    } else if (riskScore >= 30) {
      level = HazardLevel.caution;
      message =
          'CAUTION: ${warnings.isNotEmpty ? warnings.join(', ') : 'Adverse conditions detected'}';
    } else {
      level = HazardLevel.safe;
      message = warnings.isNotEmpty
          ? 'SAFE but ${warnings.join(', ')}'
          : 'All conditions are safe for outdoor activities';
    }

    return SafetyStatus(
      level: level,
      message: message,
      time: DateTime.now(),
      riskScore: riskScore.toInt(),
      warnings: warnings,
    );
  }

  // Get recommendations based on hazard level
  static List<String> getRecommendations(HazardLevel level) {
    switch (level) {
      case HazardLevel.safe:
        return [
          '✓ Safe for outdoor activities',
          '✓ Safe to travel',
          '✓ Safe for farming operations',
        ];
      case HazardLevel.caution:
        return [
          '⚠ Use caution when outdoors',
          '⚠ Reduce speed if driving',
          '⚠ Secure loose items',
          '⚠ Stay updated with weather alerts',
        ];
      case HazardLevel.danger:
        return [
          '🚫 Avoid outdoor activities',
          '🚫 Do not travel unless necessary',
          '🚫 Secure property and stay indoors',
          '🚫 Keep emergency contacts ready',
          '🚫 Monitor weather alerts closely',
        ];
    }
  }

  // Calculate safety percentage
  static int calculateSafetyPercentage(
      double rainMm, double windSpeed, int visibility) {
    int percentage = 100;

    if (rainMm > 50)
      percentage -= 60;
    else if (rainMm > 10) percentage -= 20;

    if (windSpeed > 40)
      percentage -= 60;
    else if (windSpeed > 20) percentage -= 20;

    if (visibility < 200)
      percentage -= 60;
    else if (visibility < 500) percentage -= 25;

    return percentage.clamp(0, 100);
  }
}
