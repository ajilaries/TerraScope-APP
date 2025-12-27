class Prediction {
  final String day;
  final double temp;
  final int rainChance;

  Prediction({required this.day, required this.temp, required this.rainChance});

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      day: json['day'],
      temp: json['temp'].toDouble(),
      rainChance: json['rain_chance'],
    );
  }
}

class AIPredictService {
  final String baseUrl;

  AIPredictService({required this.baseUrl});

  Future<List<Prediction>> getPredictions(double lat, double lon,
      {int historyDays = 7}) async {
    // For demo purposes, return dummy data instead of calling API
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    return [
      Prediction(day: "Today", temp: 28.5, rainChance: 75),
      Prediction(day: "Tomorrow", temp: 30.2, rainChance: 60),
      Prediction(day: "Day 3", temp: 27.8, rainChance: 45),
      Prediction(day: "Day 4", temp: 29.1, rainChance: 30),
      Prediction(day: "Day 5", temp: 31.0, rainChance: 20),
      Prediction(day: "Day 6", temp: 26.5, rainChance: 80),
      Prediction(day: "Day 7", temp: 28.0, rainChance: 50),
    ];
  }
}
