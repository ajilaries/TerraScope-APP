import 'dart:convert';
import 'package:flutter/services.dart';

class CropService {
  static Map<String, dynamic>? _cropData;

  /// Load JSON on app startup or first use
  static Future<void> loadCrops() async {
    if (_cropData != null) return;
    try {
      final jsonString =
          await rootBundle.loadString("assets/data/crops_india.json");
      _cropData = json.decode(jsonString);
      print("✅ Crops data loaded successfully");
    } catch (e) {
      print("❌ Error loading crops data: $e");
      // Fallback data
      _cropData = _getFallbackCropData();
    }
  }

  /// Get crops for given state and district
  static Map<String, dynamic>? getDistrictCrops(String state, String district) {
    if (_cropData == null) return null;

    try {
      final states = _cropData!["states"];
      if (states[state] == null) {
        print("⚠️ State not found: $state, using fallback");
        return _getDefaultCrops();
      }

      final districts = states[state]["districts"];
      if (districts == null ||
          districts.isEmpty ||
          districts[district] == null) {
        print("⚠️ District not found: $district in $state, using fallback");
        return _getDefaultCrops();
      }

      return districts[district];
    } catch (e) {
      print("❌ Error getting crops: $e");
      return _getDefaultCrops();
    }
  }

  /// Default crops for any region
  static Map<String, dynamic> _getDefaultCrops() {
    return {
      "crops": [
        {
          "name": "Paddy",
          "suitability": 85,
          "reason": "Suitable for monsoon and well-watered regions",
          "temp": "20-35°C",
          "soil": "Clay/Loam soil"
        },
        {
          "name": "Wheat",
          "suitability": 78,
          "reason": "Good for winter season cultivation",
          "temp": "10-25°C",
          "soil": "Well-drained loamy soil"
        },
        {
          "name": "Maize",
          "suitability": 80,
          "reason": "Versatile crop suitable for multiple seasons",
          "temp": "15-30°C",
          "soil": "Well-drained fertile soil"
        },
        {
          "name": "Cotton",
          "suitability": 75,
          "reason": "Ideal for warm and moderate rainfall areas",
          "temp": "18-30°C",
          "soil": "Well-drained black/loamy soil"
        },
        {
          "name": "Sugarcane",
          "suitability": 82,
          "reason": "High-yield cash crop for suitable regions",
          "temp": "20-30°C",
          "soil": "Deep fertile loamy soil"
        }
      ]
    };
  }

  /// Fallback crop data structure
  static Map<String, dynamic> _getFallbackCropData() {
    return {
      "states": {
        "Default": {
          "districts": {"Default": _getDefaultCrops()}
        }
      }
    };
  }
}
