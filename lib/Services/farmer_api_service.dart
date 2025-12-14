import 'dart:convert';
import 'package:http/http.dart' as http;

class FarmerApiService {
  static Future<Map<String, dynamic>> getPrediction({
    required double lat,
    required double lon,
    required String soilType,
  }) async {
    final body = {
      "year": DateTime.now().year,
      "lat": lat,
      "lon": lon,
      "avg_temp": 28.0,
      "rainfall_mm": 220.3,
      "humidity": 90.4,
      "soil_moisture": 0.54,
      "crop_grown": soilType,
    };

    final response = await http.post(
      Uri.parse("http://10.0.2.2:8000/agri/planting-advice"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch predictions");
    }
  }
}
