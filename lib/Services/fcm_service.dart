import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _fcmTokenKey = 'fcm_token';
  static const String _notificationSettingsKey = 'notification_settings';

  // Notification settings
  static bool _weatherAlertsEnabled = true;
  static bool _locationAlertsEnabled = true;
  static bool _emergencyAlertsEnabled = true;
  static bool _safetyModeAlertsEnabled = true;

  // Initialize FCM and local notifications
  static Future<void> initialize() async {
    // Request permission for notifications
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Configure FCM message handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessageStatic);

    // Get and save FCM token
    await _saveFCMToken();

    // Load notification settings
    await _loadNotificationSettings();

    print('FCM Service initialized successfully');
  }

  // Request notification permissions
  static Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  // Initialize local notifications for foreground messages
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Handle foreground messages (app is open)
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.notification?.title}');

    // Show local notification
    await _showLocalNotification(message);

    // Handle specific message types
    await _processMessageData(message.data);
  }

  // Handle background messages (app is closed or in background)
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Received background message: ${message.notification?.title}');

    // Handle specific message types
    await _processMessageData(message.data);
  }

  // Static handler for background messages (required by FCM)
  static Future<void> _handleBackgroundMessageStatic(
      RemoteMessage message) async {
    print(
        'Received background message (static): ${message.notification?.title}');
    await _processMessageData(message.data);
  }

  // Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'safety_channel',
      'Safety Alerts',
      channelDescription: 'Safety and emergency notifications',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      enableLights: true,
      ledColor: Color(0xFFFF0000),
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      sound: 'notification_sound.aiff',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Safety Alert',
      message.notification?.body ?? 'Important safety information',
      details,
      payload: json.encode(message.data),
    );
  }

  // Process message data based on type
  static Future<void> _processMessageData(Map<String, dynamic> data) async {
    final messageType = data['type'];

    switch (messageType) {
      case 'weather_alert':
        await _handleWeatherAlert(data);
        break;
      case 'location_alert':
        await _handleLocationAlert(data);
        break;
      case 'emergency_alert':
        await _handleEmergencyAlert(data);
        break;
      case 'safety_mode':
        await _handleSafetyModeAlert(data);
        break;
      default:
        print('Unknown message type: $messageType');
    }
  }

  // Handle weather alert messages
  static Future<void> _handleWeatherAlert(Map<String, dynamic> data) async {
    if (!_weatherAlertsEnabled) return;

    final alertType = data['alert_type'];
    final severity = data['severity'] ?? 'moderate';

    // Log weather alert for safety history
    print('Weather alert received: $alertType (severity: $severity)');

    // Could trigger additional actions like updating safety status
    // or sending notifications to emergency contacts
  }

  // Handle location-based alert messages
  static Future<void> _handleLocationAlert(Map<String, dynamic> data) async {
    if (!_locationAlertsEnabled) return;

    final locationType = data['location_type'];
    final riskLevel = data['risk_level'] ?? 'low';

    print('Location alert received: $locationType (risk: $riskLevel)');

    // Could trigger location-specific safety recommendations
  }

  // Handle emergency alert messages
  static Future<void> _handleEmergencyAlert(Map<String, dynamic> data) async {
    if (!_emergencyAlertsEnabled) return;

    final emergencyType = data['emergency_type'];
    final urgency = data['urgency'] ?? 'high';

    print('Emergency alert received: $emergencyType (urgency: $urgency)');

    // High-priority emergency handling
    if (urgency == 'critical') {
      // Could automatically trigger emergency contact notifications
      // or activate emergency protocols
    }
  }

  // Handle safety mode alert messages
  static Future<void> _handleSafetyModeAlert(Map<String, dynamic> data) async {
    if (!_safetyModeAlertsEnabled) return;

    final modeStatus = data['mode_status'];
    final actionRequired = data['action_required'] ?? false;

    print('Safety mode alert: $modeStatus (action required: $actionRequired)');

    // Could update safety mode status or trigger specific actions
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      final data = json.decode(payload) as Map<String, dynamic>;
      // Navigate to appropriate screen based on notification type
      print('Notification tapped with payload: $data');
    }
  }

  // Save FCM token for server-side messaging
  static Future<void> _saveFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_fcmTokenKey, token);
        print('FCM Token saved: $token');
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  // Get saved FCM token
  static Future<String?> getFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fcmTokenKey);
  }

  // Load notification settings
  static Future<void> _loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settings = prefs.getString(_notificationSettingsKey);

      if (settings != null) {
        final settingsMap = json.decode(settings) as Map<String, dynamic>;
        _weatherAlertsEnabled = settingsMap['weather_alerts'] ?? true;
        _locationAlertsEnabled = settingsMap['location_alerts'] ?? true;
        _emergencyAlertsEnabled = settingsMap['emergency_alerts'] ?? true;
        _safetyModeAlertsEnabled = settingsMap['safety_mode_alerts'] ?? true;
      }
    } catch (e) {
      print('Error loading notification settings: $e');
    }
  }

  // Save notification settings
  static Future<void> _saveNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settings = {
        'weather_alerts': _weatherAlertsEnabled,
        'location_alerts': _locationAlertsEnabled,
        'emergency_alerts': _emergencyAlertsEnabled,
        'safety_mode_alerts': _safetyModeAlertsEnabled,
      };
      await prefs.setString(_notificationSettingsKey, json.encode(settings));
    } catch (e) {
      print('Error saving notification settings: $e');
    }
  }

  // Update notification settings
  static Future<void> updateNotificationSettings({
    bool? weatherAlerts,
    bool? locationAlerts,
    bool? emergencyAlerts,
    bool? safetyModeAlerts,
  }) async {
    if (weatherAlerts != null) _weatherAlertsEnabled = weatherAlerts;
    if (locationAlerts != null) _locationAlertsEnabled = locationAlerts;
    if (emergencyAlerts != null) _emergencyAlertsEnabled = emergencyAlerts;
    if (safetyModeAlerts != null) _safetyModeAlertsEnabled = safetyModeAlerts;

    await _saveNotificationSettings();
  }

  // Get current notification settings
  static Map<String, bool> getNotificationSettings() {
    return {
      'weather_alerts': _weatherAlertsEnabled,
      'location_alerts': _locationAlertsEnabled,
      'emergency_alerts': _emergencyAlertsEnabled,
      'safety_mode_alerts': _safetyModeAlertsEnabled,
    };
  }

  // Subscribe to topic for location-based notifications
  static Future<void> subscribeToLocationTopic(String locationId) async {
    try {
      await _firebaseMessaging.subscribeToTopic('location_$locationId');
      print('Subscribed to location topic: $locationId');
    } catch (e) {
      print('Error subscribing to location topic: $e');
    }
  }

  // Unsubscribe from location topic
  static Future<void> unsubscribeFromLocationTopic(String locationId) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic('location_$locationId');
      print('Unsubscribed from location topic: $locationId');
    } catch (e) {
      print('Error unsubscribing from location topic: $e');
    }
  }

  // Subscribe to weather alert topics
  static Future<void> subscribeToWeatherTopics() async {
    try {
      await _firebaseMessaging.subscribeToTopic('weather_alerts');
      await _firebaseMessaging.subscribeToTopic('severe_weather');
      print('Subscribed to weather alert topics');
    } catch (e) {
      print('Error subscribing to weather topics: $e');
    }
  }

  // Subscribe to emergency alert topics
  static Future<void> subscribeToEmergencyTopics() async {
    try {
      await _firebaseMessaging.subscribeToTopic('emergency_alerts');
      await _firebaseMessaging.subscribeToTopic('critical_emergency');
      print('Subscribed to emergency alert topics');
    } catch (e) {
      print('Error subscribing to emergency topics: $e');
    }
  }

  // Send test notification (for debugging)
  static Future<void> sendTestNotification({
    required String title,
    required String body,
    String? type,
  }) async {
    final testMessage = RemoteMessage(
      notification: RemoteNotification(
        title: title,
        body: body,
      ),
      data: {
        'type': type ?? 'test',
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );

    await _showLocalNotification(testMessage);
  }

  // Clean up resources
  static Future<void> dispose() async {
    // Cancel any ongoing subscriptions or timers if needed
    print('FCM Service disposed');
  }
}
