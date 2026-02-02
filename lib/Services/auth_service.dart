
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final String baseUrl = "http://192.168.120.189:8000"; // Updated for physical device connecting to laptop backend

  // Login method using Firebase Auth
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // First, authenticate with Firebase Auth
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Firebase Auth login successful for user: ${userCredential.user?.uid}');

      // Then, call backend API for additional user data if needed
      print('Calling backend login at: $baseUrl/auth/login');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(Duration(seconds: 10));

      final data = jsonDecode(response.body);
      print('Backend login response status: ${response.statusCode}');

      if (response.statusCode == 200 && data['success'] == true) {
        // Sign out from email/password auth and sign in with custom token
        await FirebaseAuth.instance.signOut();

        // Sign in with custom token from backend
        final firebaseToken = data['firebaseToken'];
        if (firebaseToken != null) {
          await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
          print('Signed in with custom token successfully');
        }

        // Save user data locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', data['user']['id'].toString());
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_data', jsonEncode(data['user']));
        await prefs.setBool('has_completed_signup', true);

        return {'ok': true, 'message': 'Login successful', 'user': data['user']};
      } else {
        // Firebase auth succeeded but backend failed - sign out from Firebase
        await FirebaseAuth.instance.signOut();
        return {'ok': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'ok': false, 'message': 'Login error: $e'};
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

  // Signup method using Firebase Auth
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String gender,
    required String userMode,
    required int age,
    required String phoneNumber,
    required String address,
    required String deviceToken,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      // First, create user account with Firebase Auth
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Firebase Auth signup successful for user: ${userCredential.user?.uid}');

      // Get ID token for verification
      final idToken = await userCredential.user?.getIdToken();

      // Then, call backend API for additional user data
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_token': idToken,
          'name': name,
          'email': email,
          'password': password,
          'gender': gender,
          'userMode': userMode,
          'age': age,
          'phoneNumber': phoneNumber,
          'address': address,
          'device_token': deviceToken ?? '',
          'preferences': preferences,
        }),
      );

      final data = jsonDecode(response.body);
      print('Backend signup response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Save user data locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', data['user']['id'].toString());
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_data', jsonEncode(data['user']));
        await prefs.setBool('has_completed_signup', true);

        return {
          'statusCode': response.statusCode,
          'body': response.body.isNotEmpty ? jsonDecode(response.body) : null,
        };
      } else {
        // Backend failed - delete Firebase user account
        await userCredential.user?.delete();
        return {'ok': false, 'message': data['message'] ?? 'Signup failed'};
      }
    } catch (e) {
      return {'ok': false, 'message': 'Signup error: $e'};
    }
  }

  // Send OTP
  Future<Map<String, dynamic>> sendOtp({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'ok': true, 'message': 'OTP sent successfully'};
      } else {
        return {'ok': false, 'message': data['message'] ?? 'Failed to send OTP'};
      }
    } catch (e) {
      return {'ok': false, 'message': 'Network error: $e'};
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'ok': true, 'message': 'OTP verified successfully'};
      } else {
        return {'ok': false, 'message': data['message'] ?? 'Invalid OTP'};
      }
    } catch (e) {
      return {'ok': false, 'message': 'Network error: $e'};
    }
  }

  // Reset password with OTP
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'ok': true, 'message': 'Password reset successful'};
      } else {
        return {'ok': false, 'message': data['message'] ?? 'Password reset failed'};
      }
    } catch (e) {
      return {'ok': false, 'message': 'Network error: $e'};
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
    await prefs.remove('user_id');
    await prefs.remove('auth_token');
    await prefs.remove('user_data');

    // Sign out from Firebase Auth
    try {
      await FirebaseAuth.instance.signOut();
      print('Firebase Auth sign-out successful');
    } catch (firebaseError) {
      print('Firebase Auth sign-out failed: $firebaseError');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userId = prefs.getString('user_id');
    return token != null && userId != null;
  }


}
