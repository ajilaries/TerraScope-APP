import 'dart:convert';
import 'package:http/http.dart' as http;

class FarmerApiService {
  static const String baseUrl = "http://10.0.2.2:8000";

  static Future<Map<String, dynamic>> getPrediction({
    required double lat,
    required double lon,
    required String soilType,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/ai/predict"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "lat": lat,
        "lon": lon,
        "soil_type": soilType,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch prediction");
    }
  }
}
