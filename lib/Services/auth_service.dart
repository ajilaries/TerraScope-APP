import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl =
      "http://10.0.2.2:8000"; // Android emulator -> localhost. Use 127.0.0.1 on real device or device IP.

  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String gender,
    required String userMode,
    required int age,
    required String phoneNumber,
    required String address,
    List<Map<String, dynamic>>? emergencyContacts,
    bool? enableNotifications,
    bool? enableLocationSharing,
  }) async {
    final url = Uri.parse("$baseUrl/auth/signup");
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "gender": gender,
        "user_mode": userMode,
        "age": age,
        "phone_number": phoneNumber,
        "address": address,
        "emergency_contacts": emergencyContacts,
        "enable_notifications": enableNotifications,
        "enable_location_sharing": enableLocationSharing,
      }),
    );
    return {
      "statusCode": resp.statusCode,
      "body": resp.body.isEmpty ? null : jsonDecode(resp.body)
    };
  }

  Future<Map<String, dynamic>> sendOtp({required String email}) async {
    final url = Uri.parse("$baseUrl/auth/send-otp");
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email}),
    );
    return {
      "statusCode": resp.statusCode,
      "body": resp.body.isEmpty ? null : jsonDecode(resp.body)
    };
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse("$baseUrl/auth/verify-otp");
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "otp": otp}),
    );
    return {
      "statusCode": resp.statusCode,
      "body": resp.body.isEmpty ? null : jsonDecode(resp.body)
    };
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final url = Uri.parse("$baseUrl/auth/reset-password");
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "otp": otp,
        "new_password": newPassword,
      }),
    );
    return {
      "statusCode": resp.statusCode,
      "body": resp.body.isEmpty ? null : jsonDecode(resp.body)
    };
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/auth/login");
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "password": password}),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      final token = data['token'] ?? data['access_token'] ?? data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      // Save mode if backend returns it
      if (data['user'] != null && data['user']['mode'] != null) {
        await prefs.setString('user_mode', data['user']['mode']);
      }
      // Save user ID for offline access
      if (data['user'] != null && data['user']['id'] != null) {
        await saveUserId(data['user']['id'].toString());
      }
      return {"ok": true, "data": data};
    } else {
      return {"ok": false, "message": resp.body};
    }
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  Future<String?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
}
