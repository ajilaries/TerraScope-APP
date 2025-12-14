class FarmerPrediction {
  final int bestPlantingMonth;
  final double expectedYield;
  final String yieldRisk;
  final Map<int, double> monthWiseYield;

  FarmerPrediction({
    required this.bestPlantingMonth,
    required this.expectedYield,
    required this.yieldRisk,
    required this.monthWiseYield,
  });

  factory FarmerPrediction.fromJson(Map<String, dynamic> json) {
    return FarmerPrediction(
      bestPlantingMonth: json['best_planting_month'],
      expectedYield: (json['expected_yield'] as num).toDouble(),
      yieldRisk: json['yield_risk'],
      monthWiseYield: (json['month_wise_yield'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(int.parse(k), (v as num).toDouble())),
    );
  }
}
