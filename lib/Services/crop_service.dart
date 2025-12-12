import 'dart:convert';
import 'package:flutter/services.dart';

class CropService {
  static Map<String, dynamic>? _cropData;

  /// Load JSON on app startup or first use
  static Future<void> loadCrops() async {
    if (_cropData != null) return;
    final jsonString = await rootBundle.loadString("assets/data/crops_india.json");
    _cropData = json.decode(jsonString);
  }

  /// Get crops for given state and district
  static Map<String, dynamic>? getDistrictCrops(String state, String district) {
    if (_cropData == null) return null;

    final states = _cropData!["states"];
    if (states[state] == null) return null;

    final districts = states[state]["districts"];
    return districts[district];
  }
}
