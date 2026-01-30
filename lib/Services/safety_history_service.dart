import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/safety_alert.dart';
import '../models/saftey_status.dart';
import 'auth_service.dart';

class SafetyHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<String?> _getUserId() async {
    final token = await _authService.getSavedToken();
    if (token != null) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        return decodedToken['user_id'] ??
            decodedToken['id'] ??
            decodedToken['sub'];
      } catch (e) {
        print('Error decoding JWT: $e');
        return null;
      }
    }
    return null;
  }

  // Save safety history to Firestore
  Future<void> saveSafetyHistory(List<SafetyAlert> history) async {
    final userId = await _getUserId();
    if (userId == null) return;

    try {
      // Limit to last 50 entries to prevent excessive storage
      final limitedHistory = history.length > 50 ? history.sublist(history.length - 50) : history;

      final historyJson = limitedHistory
          .map((alert) => {
                'level': alert.level.toString(),
                'message': alert.message,
                'timestamp': alert.timestamp.millisecondsSinceEpoch,
                'rainMm': alert.rainMm,
                'windSpeed': alert.windSpeed,
                'visibility': alert.visibility,
                'temperature': alert.temperature,
                'humidity': alert.humidity,
                'userId': alert.userId,
              })
          .toList();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('safety_history')
          .doc('history')
          .set({
            'alerts': historyJson,
            'lastUpdated': DateTime.now().millisecondsSinceEpoch,
          });
    } catch (e) {
      throw Exception('Failed to save safety history: $e');
    }
  }

  // Load safety history from Firestore
  Future<List<SafetyAlert>> loadSafetyHistory() async {
    final userId = await _getUserId();
    if (userId == null) return [];

    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('safety_history')
          .doc('history')
          .get();

      if (doc.exists && doc.data() != null) {
        final alertsList = doc.data()!['alerts'] as List;
        return alertsList
            .map((item) => SafetyAlert(
                  level: HazardLevel.values.firstWhere(
                    (e) => e.toString() == item['level'],
                    orElse: () => HazardLevel.safe,
                  ),
                  message: item['message'],
                  timestamp:
                      DateTime.fromMillisecondsSinceEpoch(item['timestamp']),
                  rainMm: item['rainMm']?.toDouble() ?? 0.0,
                  windSpeed: item['windSpeed']?.toDouble() ?? 0.0,
                  visibility: item['visibility'] ?? 10000,
                  temperature: item['temperature']?.toDouble() ?? 25.0,
                  humidity: item['humidity']?.toInt() ?? 50,
                  userId: item['userId'] ?? userId,
                ))
            .toList();
      }
    } catch (e) {
      print('Failed to load safety history: $e');
    }
    return [];
  }

  // Add a single safety alert
  Future<void> addSafetyAlert(SafetyAlert alert) async {
    final history = await loadSafetyHistory();
    history.insert(0, alert); // Add to beginning
    await saveSafetyHistory(history);
  }

  // Clear safety history
  Future<void> clearSafetyHistory() async {
    final userId = await _getUserId();
    if (userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('safety_history')
          .doc('history')
          .delete();
    } catch (e) {
      throw Exception('Failed to clear safety history: $e');
    }
  }

  // Get safety statistics
  Future<Map<String, dynamic>> getSafetyStatistics() async {
    final history = await loadSafetyHistory();

    if (history.isEmpty) {
      return {
        'totalAlerts': 0,
        'dangerCount': 0,
        'cautionCount': 0,
        'safeCount': 0,
        'mostCommonLevel': 'safe',
      };
    }

    final dangerCount = history.where((alert) => alert.level == HazardLevel.danger).length;
    final cautionCount = history.where((alert) => alert.level == HazardLevel.caution).length;
    final safeCount = history.where((alert) => alert.level == HazardLevel.safe).length;

    HazardLevel mostCommonLevel;
    if (dangerCount >= cautionCount && dangerCount >= safeCount) {
      mostCommonLevel = HazardLevel.danger;
    } else if (cautionCount >= safeCount) {
      mostCommonLevel = HazardLevel.caution;
    } else {
      mostCommonLevel = HazardLevel.safe;
    }

    return {
      'totalAlerts': history.length,
      'dangerCount': dangerCount,
      'cautionCount': cautionCount,
      'safeCount': safeCount,
      'mostCommonLevel': mostCommonLevel.toString().split('.').last,
    };
  }
}
