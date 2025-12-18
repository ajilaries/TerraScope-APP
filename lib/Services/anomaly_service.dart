import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class AnomalyService {
  static const String _anomalyUrl =
      "http://10.0.2.2:8000/get_anomalies";

  /// 🌪️ Main anomaly provider (backend → fallback)
  Future<List<Map<String, dynamic>>> getAnomalies({
    required double lat,
    required double lon,
    WeatherData? weather,
  }) async {
    // 1️⃣ Try backend first
    final backendAlerts = await _fetchFromBackend(lat, lon);

    if (backendAlerts.isNotEmpty) {
      return backendAlerts;
    }

    // 2️⃣ Fallback to local detection
    if (weather != null) {
      return detectFromWeather(weather);
    }

    // 3️⃣ Absolute fallback
    return [
      _buildAlert(
        type: "Normal",
        message: "No anomalies detected",
        severity: "clear",
      )
    ];
  }

  /// 🌐 Backend anomaly fetch
  Future<List<Map<String, dynamic>>> _fetchFromBackend(
      double lat, double lon) async {
    try {
      final response = await http.post(
        Uri.parse(_anomalyUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"lat": lat, "lon": lon}),
      );

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);

      if (data["status"] != "success") return [];

      return List<Map<String, dynamic>>.from(
        data["anomalies"].map((a) {
          return _buildAlert(
            type: a["type"] ?? "Unknown",
            message: a["message"] ?? "Anomaly detected",
            severity: a["severity"] ?? "warning",
            confidence: a["confidence"],
          );
        }),
      );
    } catch (e) {
      print("⚠️ Backend anomaly fetch failed: $e");
      return [];
    }
  }

  /// 🧠 Offline-safe anomaly detection
  List<Map<String, dynamic>> detectFromWeather(WeatherData w) {
    final List<Map<String, dynamic>> alerts = [];

    if (w.rainfall >= 20) {
      alerts.add(_buildAlert(
        type: "Heavy Rain",
        message: "Flooding risk due to heavy rainfall",
        severity: "danger",
      ));
    }

    if (w.temperature >= 40) {
      alerts.add(_buildAlert(
        type: "Heat Alert",
        message: "Extreme heat may damage crops",
        severity: "warning",
      ));
    }

    if (w.windSpeed >= 35) {
      alerts.add(_buildAlert(
        type: "Strong Wind",
        message: "Avoid spraying pesticides",
        severity: "warning",
      ));
    }

    if (alerts.isEmpty) {
      alerts.add(_buildAlert(
        type: "Normal",
        message: "No anomalies detected",
        severity: "clear",
      ));
    }

    return alerts;
  }

  /// 🧱 Unified alert builder
  Map<String, dynamic> _buildAlert({
    required String type,
    required String message,
    required String severity,
    double? confidence,
  }) {
    return {
      "type": type,
      "message": message,
      "severity": severity, // clear | warning | danger
      "confidence": confidence ?? 0.0,
      "timestamp": DateTime.now().toIso8601String(),
    };
  }
}
