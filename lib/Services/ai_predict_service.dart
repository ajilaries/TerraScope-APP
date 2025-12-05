import 'dart:convert';
import 'package:http/http.dart' as http;

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

  Future<List<Prediction>> getPredictions(double lat, double lon, {int historyDays = 7}) async {
    final url = Uri.parse('$baseUrl/ai/predict');

    final response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "lat": lat,
          "lon": lon,
          "history_days": historyDays,
        }));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List predictions = data['predictions'];
      return predictions.map((p) => Prediction.fromJson(p)).toList();
    } else {
      throw Exception("Failed to fetch AI predictions");
    }
  }
}
