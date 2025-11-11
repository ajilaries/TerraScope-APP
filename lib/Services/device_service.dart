import 'dart:convert';
import 'package:http/http.dart' as http;
import 'location_service.dart'; // Make sure this path is correct

class DeviceService {
  static const String backendUrl = "http://10.0.2.2:8000/save_device";

  /// ✅ Get or generate a device token
  static String getDeviceToken() {
    // Access the singleton LocationService instance
    final locationService = LocationService();

    // If token already exists, return it
    if (locationService.deviceToken != null &&
        locationService.deviceToken!.isNotEmpty) {
      return locationService.deviceToken!;
    }

    // Otherwise, generate a new token
    final newToken = "DEVICE_TOKEN_${DateTime.now().millisecondsSinceEpoch}";
    locationService.deviceToken = newToken;
    return newToken;
  }

  /// ✅ Register device to backend
  static Future<void> registerDevice({required double lat, required double lon}) async {
    final token = getDeviceToken();

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token, "lat": lat, "lon": lon}),
      );

      if (response.statusCode == 200) {
        print("Device registered successfully");
      } else {
        print("Failed to register device: ${response.body}");
      }
    } catch (e) {
      print("Error registering device: $e");
    }
  }
}
