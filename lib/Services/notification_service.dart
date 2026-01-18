import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
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

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(settings);

    // Request permissions
    await _firebaseMessaging.requestPermission();
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
    await showNotification(
      title: message.notification?.title ?? 'Safety Alert',
      body: message.notification?.body ?? 'Weather safety update',
      payload: message.data.toString(),
    );
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    print('Handling foreground message: ${message.messageId}');
    showNotification(
      title: message.notification?.title ?? 'Safety Alert',
      body: message.notification?.body ?? 'Weather safety update',
      payload: message.data.toString(),
    );
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'safety_channel',
      'Safety Alerts',
      channelDescription: 'Weather and safety notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher', // Explicitly set the icon
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
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

  static Future<void> sendEmergencyAlert({
    required String title,
    required String body,
    String? payload,
  }) async {
    await showNotification(
      title: title,
      body: body,
      payload: payload,
    );
  }
}
