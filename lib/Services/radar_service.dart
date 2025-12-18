import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RadarService {
  final String _apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  Future<Map<String, dynamic>> getRadarWeatherData(double lat, double lon) async {
    if (_apiKey.isEmpty) {
      throw Exception("API key not found. Check .env file");
    }

    final url =
  "https://api.openweathermap.org/data/3.0/onecall"
  "?lat=$lat&lon=$lon"
  "&exclude=minutely,daily"
  "&units=metric"
  "&appid=$_apiKey";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Radar API error: ${response.statusCode}");
      }
    } catch (e) {
      print("Radar fetch failed: $e");
      return {};
    }
  }
}
