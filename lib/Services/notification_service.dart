import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static Future<String?> getDeviceToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request notification permission
    await messaging.requestPermission();

    // Get device FCM token
    String? token = await messaging.getToken();
    return token;
  }
}
