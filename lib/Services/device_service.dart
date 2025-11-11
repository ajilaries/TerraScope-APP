import 'dart:convert';
import 'package:http/http.dart' as http;

class DeviceService {
  static const String backendUrl = "https://backendurl/save_device";
  static Future<void> registerDevice(
    String token,
    double lat,
    double lon,
  ) async {
    await http.post(
      Uri.parse(backendUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"token": token, "lat": lat, "lon": lon}),
    );
  }
}
