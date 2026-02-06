
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:terra_scope_apk/Services/auth_service.dart';
import 'package:terra_scope_apk/Services/local_notification_service.dart';

class DailyPlannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<String?> _getUserId() async {
    // First try to get saved user ID
    final savedUserId = await _authService.getSavedUserId();
    if (savedUserId != null) {
      return savedUserId;
    }

    // Fallback to JWT decoding
    final token = await _authService.getSavedToken();
    if (token != null) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        final userId = decodedToken['user_id'] ??
            decodedToken['id'] ??
            decodedToken['sub'];
        if (userId != null) {
          // Save for future use
          await _authService.saveUserId(userId.toString());
          return userId.toString();
        }
      } catch (e) {
        print('Error decoding JWT: $e');
        return null;
      }
    }
    return null;
  }

  // Schedule methods
  Future<List<Map<String, dynamic>>> getSchedules() async {
    final userId = await _getUserId();
    if (userId == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('schedules')
        .orderBy('date', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data(),
            })
        .toList();
  }

  Future<void> addSchedule(Map<String, dynamic> schedule) async {
    final userId = await _getUserId();
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('schedules')
        .add(schedule);
  }

  Future<void> updateSchedule(
      String scheduleId, Map<String, dynamic> schedule) async {
    final userId = await _getUserId();
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('schedules')
        .doc(scheduleId)
        .update(schedule);
  }

  Future<void> deleteSchedule(String scheduleId) async {
    final userId = await _getUserId();
    if (userId == null) return;

    // Cancel any scheduled notifications for this schedule
    await LocalNotificationService.cancelNotification(scheduleId.hashCode);

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('schedules')
        .doc(scheduleId)
        .delete();
  }

  // Tasks methods
  Future<List<Map<String, dynamic>>> getTasks() async {
    final userId = await _getUserId();
    if (userId == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data(),
            })
        .toList();
  }

  Future<void> addTask(Map<String, dynamic> task) async {
    final userId = await _getUserId();
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .add(task);
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> task) async {
    final userId = await _getUserId();
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .update(task);
  }

  Future<void> deleteTask(String taskId) async {
    final userId = await _getUserId();
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  // Reminders methods
  Future<List<Map<String, dynamic>>> getReminders() async {
    final userId = await _getUserId();
    if (userId == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .orderBy('reminderTime', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data(),
            })
        .toList();
  }

  Future<void> addReminder(Map<String, dynamic> reminder) async {
    final userId = await _getUserId();
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .add(reminder);
  }

  Future<void> updateReminder(
      String reminderId, Map<String, dynamic> reminder) async {
    final userId = await _getUserId();
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .doc(reminderId)
        .update(reminder);
  }

  Future<void> deleteReminder(String reminderId) async {
    final userId = await _getUserId();
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .doc(reminderId)
        .delete();
  }
}
