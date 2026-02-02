import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DeviceService {
  static const String backendUrl = "http://192.168.120.189:8001/save_device";
  static const String _prefKey = "device_token";

  /// ✅ Get or generate a persistent device token
  static Future<String> getDeviceToken() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString(_prefKey);

    if (token != null && token.isNotEmpty) return token;

    // Generate a new token if none exists
    token = "DEVICE_TOKEN_${DateTime.now().millisecondsSinceEpoch}";
    await prefs.setString(_prefKey, token);

    return token;
  }

  /// ✅ Register device to backend
  static Future<void> registerDevice({
    required double lat,
    required double lon,
  }) async {
    final token = await getDeviceToken();

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "lat": lat,
          "lon": lon,
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Device registered successfully");
      } else {
        print("❌ Failed to register device: ${response.body}");
      }
    } catch (e) {
      print("❌ Error registering device: $e");
    }
  }
}
