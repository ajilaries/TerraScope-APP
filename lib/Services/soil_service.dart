import 'dart:convert';
import 'package:http/http.dart' as http;

class SoilService {
  static Future<String> getSoilType(double lat, double lon) async {
    try {
      final url = "https://rest.isric.org/soilgrids/v2.0/properties/query"
          "?lat=$lat&lon=$lon&property=texture_class&depth=0-5cm";
      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception("Soil API timeout"),
          );

      if (response.statusCode != 200) {
        throw Exception("Soil API Failed: ${response.statusCode}");
      }
      final data = json.decode(response.body);

      // Extract texture class - Fixed typo: 'properties' instead of 'propreties'
      final layers = data['properties']['layers'];
      final texture = layers[0]['depths'][0]['values']['values'];

      return texture.toString();
    } catch (e) {
      print("❌ Soil Service Error: $e");
      // Return default soil type if API fails
      return "Clay";
    }
  }
}
