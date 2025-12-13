class FarmerPrediction {
  final double temperature;
  final double rainfall;
  final String crop;
  final String risk;
  final String suggestion;

  FarmerPrediction({
    required this.temperature,
    required this.rainfall,
    required this.crop,
    required this.risk,
    required this.suggestion,
  });

  factory FarmerPrediction.fromJson(Map<String, dynamic> json) {
    return FarmerPrediction(
      temperature: json['predicted_weather']['temperature'].toDouble(),
      rainfall: json['predicted_weather']['rainfall'].toDouble(),
      crop: json['best_crop'],
      risk: json['risk_level'],
      suggestion: json['suggestion'],
    );
  }
}
