class WeatherData {
  final double temperature;
  final double rainfall;
  final double humidity;
  final double windSpeed;
  final String condition;

  WeatherData({
    required this.temperature,
    required this.rainfall,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json["temperature"] ?? 0).toDouble(),
      rainfall: (json["rainfall"] ?? 0).toDouble(),
      humidity: (json["humidity"] ?? 50).toDouble(),
      windSpeed: (json["wind_speed"] ?? 3.5).toDouble(),
      condition: json["condition"] ?? "Unknown",
    );
  }

  static fromMap(Map<String, dynamic> weatherRaw) {}
}
