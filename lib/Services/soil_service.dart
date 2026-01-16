import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class SoilService {
  static Future<String> getSoilType(double lat, double lon) async {
    try {
      // Try the v2.0 API first
      final url = "https://rest.isric.org/soilgrids/v2.0/properties/query"
          "?lat=$lat&lon=$lon&property=texture_class&depth=0-5cm&value=mean";

      print("🌍 Soil API Request: $url");

      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception("Soil API timeout"),
          );

      print("🌍 Soil API Response Status: ${response.statusCode}");

      if (response.statusCode != 200) {
        // Try alternative API endpoint if v2.0 fails
        print("❌ v2.0 API failed, trying alternative endpoint");
        return await _getSoilTypeAlternative(lat, lon);
      }

      final data = json.decode(response.body);
      print(
          "🌍 Soil API Response: ${data.toString().substring(0, min(200, data.toString().length))}");

      // Extract texture class from v2.0 API response
      if (data['properties'] != null &&
          data['properties']['layers'] != null &&
          data['properties']['layers'].isNotEmpty) {
        final layers = data['properties']['layers'];
        if (layers[0]['depths'] != null && layers[0]['depths'].isNotEmpty) {
          final depths = layers[0]['depths'];
          if (depths[0]['values'] != null &&
              depths[0]['values']['mean'] != null) {
            final textureCode = depths[0]['values']['mean'];
            print("🌍 Soil Texture Code: $textureCode");
            return _mapTextureClassToName(textureCode);
          }
        }
      }

      // If we can't parse the response, try alternative
      print("❌ Could not parse v2.0 response, trying alternative");
      return await _getSoilTypeAlternative(lat, lon);
    } catch (e) {
      print("❌ Soil Service Error: $e");
      // Try alternative method
      try {
        return await _getSoilTypeAlternative(lat, lon);
      } catch (altError) {
        print("❌ Alternative soil service also failed: $altError");
        return "Unknown";
      }
    }
  }

  // Alternative soil type method using different approach
  static Future<String> _getSoilTypeAlternative(double lat, double lon) async {
    try {
      // Use a simpler approach - estimate based on common soil types for the region
      // This is a fallback when the API is not available
      print("🌍 Using alternative soil type estimation");

      // For demonstration, return common soil types based on location
      // In a real implementation, you might use a local database or different API
      if (lat >= 8.0 && lat <= 13.0 && lon >= 76.0 && lon <= 78.0) {
        // Kerala region - often has clay loam or alluvial soils
        return "Clay Loam";
      } else if (lat >= 12.0 && lat <= 15.0 && lon >= 78.0 && lon <= 81.0) {
        // Tamil Nadu region - often has red soils
        return "Red Soil";
      } else if (lat >= 15.0 && lat <= 19.0 && lon >= 78.0 && lon <= 82.0) {
        // Andhra Pradesh region - often has black cotton soils
        return "Black Cotton Soil";
      } else {
        // Default for other regions
        return "Alluvial Soil";
      }
    } catch (e) {
      print("❌ Alternative soil estimation failed: $e");
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
