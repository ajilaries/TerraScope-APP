import 'dart:convert';
import 'package:http/http.dart' as http;

class AQIService {
  static const String aqiUrl =
      "http://10.0.2.2:8000/get_aqi";

  Future<int?> getAQI(double lat, double lon) async {
    try {
      final response = await http.post(
        Uri.parse(aqiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"lat": lat, "lon": lon}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["aqi"];
      }
    } catch (e) {
      print("❌ AQI fetch failed: $e");
    }

    return null;
  }

  /// 🎨 AQI category helper
  String getAQILabel(int aqi) {
    if (aqi <= 50) return "Good";
    if (aqi <= 100) return "Moderate";
    if (aqi <= 200) return "Poor";
    if (aqi <= 300) return "Very Poor";
    return "Severe";
  }
}
