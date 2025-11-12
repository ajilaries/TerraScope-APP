import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';


import 'package:http/http.dart' as http;

class NotificationService {
  static Future<String?> getDeviceToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request notification permission
    await messaging.requestPermission();

    // Get device FCM token
    String? token = await messaging.getToken();
    return token;
  }

  static Future<void> sendEmergencyAlert({
    required String message,
    required double lat,
    required double lon,
    required String userId,
  }) async {
    try {
      final url = Uri.parse("http://10.0.2.2:8000/send_alert");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "lat": lat,
          "lon": lon,
          "message": message,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception("failed to send emergency alert");
      }
      print("Emergency alert send sucessfully");
    } catch (e) {
      print("Error sending emergency alert:$e");
    }
  }
}
