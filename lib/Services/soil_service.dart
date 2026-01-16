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

      // Extract texture class - Use 'mean' value and map to soil type name
      final layers = data['properties']['layers'];
      final textureCode = layers[0]['depths'][0]['values']['mean'];

      // Map numeric texture class to soil type name
      return _mapTextureClassToName(textureCode);
    } catch (e) {
      print("❌ Soil Service Error: $e");
      // Return default soil type if API fails
      return "Unknown";
    }
  }

  static String _mapTextureClassToName(int textureCode) {
    switch (textureCode) {
      case 1:
        return "Clay";
      case 2:
        return "Silty Clay";
      case 3:
        return "Sandy Clay";
      case 4:
        return "Clay Loam";
      case 5:
        return "Silty Clay Loam";
      case 6:
        return "Sandy Clay Loam";
      case 7:
        return "Loam";
      case 8:
        return "Silty Loam";
      case 9:
        return "Sandy Loam";
      case 10:
        return "Silt";
      case 11:
        return "Loamy Sand";
      case 12:
        return "Sand";
      default:
        return "Unknown";
    }
  }
}
