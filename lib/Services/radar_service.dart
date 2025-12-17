import 'dart:convert';
import 'package:http/http.dart' as http;

class RadarService {
  static const String apiKey = "a5465304ed7d80bb3a52de825be8e2e7";

  Future<Map<String, dynamic>> getRadarLayer(double lat, double lon) async {
    final url =
        "https://api.openweathermap.org/data/2.5/weather"
        "?lat=$lat&lon=$lon&appid=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Radar fetch failed :$e");
    }

    return {};
  }
}
