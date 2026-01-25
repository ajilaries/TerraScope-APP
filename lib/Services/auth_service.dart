import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://10.0.2.2:8000"; // Android emulator -> localhost. Use 127.0.0.1 on real device or device IP.

  // Login method
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save token and user ID
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['access_token']);
        await prefs.setString('user_id', data['user_id']);
        return {'ok': true, 'message': 'Login successful'};
      } else {
        return {'ok': false, 'message': data['detail'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'ok': false, 'message': 'Network error: $e'};
    }
  }

  // Send verification link for email verification
  Future<Map<String, dynamic>> sendVerificationLink({required String email}) async {
    final startTime = DateTime.now();
    try {
      print('Sending verification link request to: $baseUrl/auth/send-verification-link');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-verification-link'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print('Verification link send response time: ${duration.inMilliseconds}ms, Status: ${response.statusCode}');

      return {
        'statusCode': response.statusCode,
        'body': response.body.isNotEmpty ? jsonDecode(response.body) : null,
      };
    } catch (e) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print('Verification link send failed after ${duration.inMilliseconds}ms: $e');
      return {'statusCode': 500, 'body': 'Network error: $e'};
    }
  }

  // Send reset link for password reset
  Future<Map<String, dynamic>> sendResetLink({required String email}) async {
    final startTime = DateTime.now();
    try {
      print('Sending reset link request to: $baseUrl/auth/send-reset-link');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-reset-link'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print('Reset link send response time: ${duration.inMilliseconds}ms, Status: ${response.statusCode}');

      return {
        'statusCode': response.statusCode,
        'body': response.body.isNotEmpty ? jsonDecode(response.body) : null,
      };
    } catch (e) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print('Reset link send failed after ${duration.inMilliseconds}ms: $e');
      return {'statusCode': 500, 'body': 'Network error: $e'};
    }
  }

  // Signup method
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String gender,
    required String userMode,
    required int age,
    required String phoneNumber,
    required String address,
    required List<Map<String, dynamic>> emergencyContacts,
    required bool enableNotifications,
    required bool enableLocationSharing,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'gender': gender,
          'user_mode': userMode,
          'age': age,
          'phone_number': phoneNumber,
          'address': address,
          'emergency_contacts': emergencyContacts,
          'enable_notifications': enableNotifications,
          'enable_location_sharing': enableLocationSharing,
        }),
      );

      return {
        'statusCode': response.statusCode,
        'body': response.body.isNotEmpty ? jsonDecode(response.body) : null,
      };
    } catch (e) {
      return {'statusCode': 500, 'body': 'Network error: $e'};
    }
  }

  // Reset password (used after clicking reset link)
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'new_password': newPassword,
        }),
      );

      return {
        'statusCode': response.statusCode,
        'body': response.body.isNotEmpty ? jsonDecode(response.body) : null,
      };
    } catch (e) {
      return {'statusCode': 500, 'body': 'Network error: $e'};
    }
  }

  // Get saved user ID
  Future<String?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // Get saved token
  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Save user ID
  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getSavedToken();
    return token != null;
  }
}
