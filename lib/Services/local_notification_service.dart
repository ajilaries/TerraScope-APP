import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Initialize notification settings
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

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'schedule_channel',
        'Schedule Notifications',
        channelDescription: 'Notifications for scheduled events',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(id, title, body, details, payload: payload);
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'schedule_reminder_channel',
        'Schedule Reminders',
        channelDescription: 'Reminders for scheduled events',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
    // You can navigate to specific screen or perform action here
  }

  // Schedule a reminder notification for a schedule
  static Future<void> scheduleScheduleReminder({
    required int scheduleId,
    required String title,
    required String description,
    required DateTime scheduleDate,
    int minutesBefore = 15, // Default 15 minutes before
  }) async {
    final reminderTime = scheduleDate.subtract(Duration(minutes: minutesBefore));

    // Only schedule if reminder time is in the future
    if (reminderTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: scheduleId,
        title: 'Upcoming Schedule: $title',
        body: description.isNotEmpty
            ? '$description\nScheduled for ${scheduleDate.toString()}'
            : 'Scheduled for ${scheduleDate.toString()}',
        scheduledDate: reminderTime,
        payload: 'schedule_$scheduleId',
      );
    }
  }

  // Show immediate notification when schedule is added
  static Future<void> showScheduleAddedNotification(String title) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
      title: 'Schedule Added',
      body: '$title has been added to your schedule',
      payload: 'schedule_added',
    );
  }
}
