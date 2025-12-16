import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class AnomalyService {
  static const String anomalyUrl = "http://10.0.2.2:8000/get_anomalies";

  /// 🌪️ Fetch anomalies from backend
  Future<List<Map<String, dynamic>>> getAnomalies({
    required double lat,
    required double lon,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(anomalyUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"lat": lat, "lon": lon}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["status"] == "success") {
          return List<Map<String, dynamic>>.from(data["anomalies"]);
        }
      }
    } catch (e) {
      print("⚠️ Backend anomaly fetch failed: $e");
    }

    return [];
  }

  /// 🧠 Local fallback anomaly detection (offline safe)
  List<Map<String, dynamic>> detectFromWeather(WeatherData w) {
    final List<Map<String, dynamic>> alerts = [];

    if (w.rainfall >= 20) {
      alerts.add({
        "type": "Heavy Rain",
        "message": "Flooding risk due to heavy rainfall",
      });
    }

    if (w.temperature >= 40) {
      alerts.add({
        "type": "Heat Alert",
        "message": "Extreme heat may damage crops",
      });
    }

    if (w.windSpeed >= 35) {
      alerts.add({
        "type": "Strong Wind",
        "message": "Avoid spraying pesticides",
      });
    }

    if (alerts.isEmpty) {
      alerts.add({"type": "Normal", "message": "No anomalies detected"});
    }

    return alerts;
  }
}
