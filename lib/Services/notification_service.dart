import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final AuthService _authService = AuthService();
  static String? _currentUserId;

  static Future<void> initialize() async {
    // Set current user for user-specific preferences
    try {
      _currentUserId = await _authService.getSavedUserId();
      print(
          'Notification service initialized for user: ${_currentUserId ?? 'guest'}');
    } catch (e) {
      print('Error setting current user for notifications: $e');
      _currentUserId = null;
    }

    // Request permissions for FCM
    await _firebaseMessaging.requestPermission();

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages (optional: can be removed to let FCM handle display)
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
    // FCM will automatically display the notification on Android
    // On iOS, you might need to handle it differently
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    print('Handling foreground message: ${message.messageId}');
    // For foreground messages, FCM does not display notifications automatically
    // You can choose to show a local notification here if needed, but since we're removing local notifications,
    // we can just log or handle data payload
    _processMessageData(message.data);
  }

  static void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.messageId}');
    // Handle navigation or actions when notification is tapped
    _processMessageData(message.data);
  }

  static void _processMessageData(Map<String, dynamic> data) {
    // Process any data payload from the notification
    print('Processing message data: $data');
    // Add logic to handle specific data types if needed
  }

  static Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'notifications_enabled_${_currentUserId ?? 'guest'}';
    return prefs.getBool(key) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'notifications_enabled_${_currentUserId ?? 'guest'}';
    await prefs.setBool(key, enabled);
  }

  static Future<String?> getDeviceToken() async {
    return await getFCMToken();
  }

  // Note: Notifications are now handled by FCM server-side
  // Use Firebase Admin SDK or Cloud Functions to send notifications
}
