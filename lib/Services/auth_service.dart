import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://10.0.2.2:8000"; // Android emulator -> localhost. Use 127.0.0.1 on real device or device IP.

  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String gender,
    required String userMode,
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
        "user_mode": userMode
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
      return {"ok": true, "data": data};
    } else {
      return {"ok": false, "message": resp.body};
    }
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }
}
