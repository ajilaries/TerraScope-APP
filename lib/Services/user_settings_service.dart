import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'nearby_cache_service.dart';
import 'offline_service.dart';

class UserSettingsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final AuthService _authService = AuthService();

  // Get current user ID from Firebase Auth
  static Future<String?> _getCurrentUserId() async {
    final user = _auth.currentUser;
    return user?.uid;
  }

  // Get user settings document reference
  static Future<DocumentReference?> _getUserSettingsRef() async {
    final userId = await _getCurrentUserId();
    if (userId == null) return null;

    return _firestore.collection('user_settings').doc(userId);
  }

  // ==================== HEALTH REMINDERS ====================

  static Future<List<Map<String, dynamic>>> getHealthReminders() async {
    try {
      final settingsRef = await _getUserSettingsRef();
      if (settingsRef == null) return [];

      final doc = await settingsRef.get();
      if (!doc.exists) return [];

      final data = doc.data() as Map<String, dynamic>;
      final reminders = data['health_reminders'] as List<dynamic>? ?? [];

      return reminders
          .map((reminder) => reminder as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting health reminders: $e');
      return [];
    }
  }

  static Future<void> saveHealthReminders(
      List<Map<String, dynamic>> reminders) async {
    try {
      final settingsRef = await _getUserSettingsRef();
      if (settingsRef == null) return;

      await settingsRef.set({
        'health_reminders': reminders,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving health reminders: $e');
    }
  }

  static Future<void> addHealthReminder(Map<String, dynamic> reminder) async {
    try {
      final reminders = await getHealthReminders();
      reminders.add(reminder);
      await saveHealthReminders(reminders);
    } catch (e) {
      print('Error adding health reminder: $e');
    }
  }

  static Future<void> updateHealthReminder(
      String reminderId, Map<String, dynamic> updatedReminder) async {
    try {
      final reminders = await getHealthReminders();
      final index = reminders.indexWhere((r) => r['id'] == reminderId);
      if (index != -1) {
        reminders[index] = updatedReminder;
        await saveHealthReminders(reminders);
      }
    } catch (e) {
      print('Error updating health reminder: $e');
    }
  }

  static Future<void> deleteHealthReminder(String reminderId) async {
    try {
      final reminders = await getHealthReminders();
      reminders.removeWhere((r) => r['id'] == reminderId);
      await saveHealthReminders(reminders);
    } catch (e) {
      print('Error deleting health reminder: $e');
    }
  }

  // ==================== DAILY ACTIVITIES ====================

  static Future<List<Map<String, dynamic>>> getDailyActivities(
      String date) async {
    try {
      final settingsRef = await _getUserSettingsRef();
      if (settingsRef == null) return [];

      final doc = await settingsRef.get();
      if (!doc.exists) return [];

      final data = doc.data() as Map<String, dynamic>;
      final activities =
          data['daily_activities'] as Map<String, dynamic>? ?? {};
      final dateActivities = activities[date] as List<dynamic>? ?? [];

      return dateActivities
          .map((activity) => activity as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting daily activities: $e');
      return [];
    }
  }

  static Future<void> saveDailyActivities(
      String date, List<Map<String, dynamic>> activities) async {
    try {
      final settingsRef = await _getUserSettingsRef();
      if (settingsRef == null) return;

      await settingsRef.set({
        'daily_activities': {
          date: activities,
        },
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving daily activities: $e');
    }
  }

  static Future<void> addDailyActivity(
      String date, Map<String, dynamic> activity) async {
    try {
      final activities = await getDailyActivities(date);
      activities.add(activity);
      await saveDailyActivities(date, activities);
    } catch (e) {
      print('Error adding daily activity: $e');
    }
  }

  static Future<void> updateDailyActivity(String date, String activityId,
      Map<String, dynamic> updatedActivity) async {
    try {
      final activities = await getDailyActivities(date);
      final index = activities.indexWhere((a) => a['id'] == activityId);
      if (index != -1) {
        activities[index] = updatedActivity;
        await saveDailyActivities(date, activities);
      }
    } catch (e) {
      print('Error updating daily activity: $e');
    }
  }

  // ==================== MEDICATION TRACKING ====================

  static Future<List<Map<String, dynamic>>> getMedications() async {
    try {
      final settingsRef = await _getUserSettingsRef();
      if (settingsRef == null) return [];

      final doc = await settingsRef.get();
      if (!doc.exists) return [];

      final data = doc.data() as Map<String, dynamic>;
      final medications = data['medications'] as List<dynamic>? ?? [];

      return medications.map((med) => med as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error getting medications: $e');
      return [];
    }
  }

  static Future<void> saveMedications(
      List<Map<String, dynamic>> medications) async {
    try {
      final settingsRef = await _getUserSettingsRef();
      if (settingsRef == null) return;

      await settingsRef.set({
        'medications': medications,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving medications: $e');
    }
  }

  // ==================== CARE PREFERENCES ====================

  static Future<Map<String, dynamic>> getCarePreferences() async {
    try {
      final settingsRef = await _getUserSettingsRef();
      if (settingsRef == null) return {};

      final doc = await settingsRef.get();
      if (!doc.exists) return {};

      final data = doc.data() as Map<String, dynamic>;
      return data['care_preferences'] as Map<String, dynamic>? ?? {};
    } catch (e) {
      print('Error getting care preferences: $e');
      return {};
    }
  }

  static Future<void> saveCarePreferences(
      Map<String, dynamic> preferences) async {
    try {
      final settingsRef = await _getUserSettingsRef();
      if (settingsRef == null) return;

      await settingsRef.set({
        'care_preferences': preferences,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving care preferences: $e');
    }
  }

  // ==================== EMERGENCY CONTACTS (BACKUP TO FIRESTORE) ====================

  static Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    try {
      final settingsRef = await _getUserSettingsRef();
      if (settingsRef == null) return [];

      final doc = await settingsRef.get();
      if (!doc.exists) return [];

      final data = doc.data() as Map<String, dynamic>;
      final contacts = data['emergency_contacts'] as List<dynamic>? ?? [];

      return contacts
          .map((contact) => contact as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting emergency contacts: $e');
      return [];
    }
  }

  static Future<void> saveEmergencyContacts(
      List<Map<String, dynamic>> contacts) async {
    try {
      final settingsRef = await _getUserSettingsRef();
      if (settingsRef == null) return;

      await settingsRef.set({
        'emergency_contacts': contacts,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving emergency contacts: $e');
    }
  }

  // ==================== USER PROFILE ====================

  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final settingsRef = await _getUserSettingsRef();
      if (settingsRef == null) return {};

      final doc = await settingsRef.get();
      if (!doc.exists) return {};

      final data = doc.data() as Map<String, dynamic>;
      return data['profile'] as Map<String, dynamic>? ?? {};
    } catch (e) {
      print('Error getting user profile: $e');
      return {};
    }
  }

  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    try {
      final settingsRef = await _getUserSettingsRef();
      if (settingsRef == null) return;

      await settingsRef.set({
        'profile': profile,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving user profile: $e');
    }
  }

  // ==================== SYNC STATUS ====================

  static Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final settingsRef = await _getUserSettingsRef();
      if (settingsRef == null) return {};

      final doc = await settingsRef.get();
      if (!doc.exists) return {};

      final data = doc.data() as Map<String, dynamic>;
      return data['sync_status'] as Map<String, dynamic>? ?? {};
    } catch (e) {
      print('Error getting sync status: $e');
      return {};
    }
  }

  static Future<void> updateSyncStatus(
      String feature, DateTime lastSync) async {
    try {
      final settingsRef = await _getUserSettingsRef();
      if (settingsRef == null) return;

      final syncStatus = await getSyncStatus();
      syncStatus[feature] = lastSync.toIso8601String();

      await settingsRef.set({
        'sync_status': syncStatus,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating sync status: $e');
    }
  }

  // ==================== DATA EXPORT/IMPORT ====================

  static Future<Map<String, dynamic>> exportUserData() async {
    try {
      final settingsRef = await _getUserSettingsRef();
      if (settingsRef == null) return {};

      final doc = await settingsRef.get();
      if (!doc.exists) return {};

      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      print('Error exporting user data: $e');
      return {};
    }
  }

  static Future<void> importUserData(Map<String, dynamic> data) async {
    try {
      final settingsRef = await _getUserSettingsRef();
      if (settingsRef == null) return;

      await settingsRef.set({
        ...data,
        'last_updated': FieldValue.serverTimestamp(),
        'imported_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error importing user data: $e');
    }
  }

  // ==================== CACHE MANAGEMENT ====================

  // Clear all app caches to reduce memory load
  static Future<void> clearAllCaches() async {
    try {
      print('Clearing all app caches...');

      // Clear nearby services cache
      await _clearNearbyCache();

      // Clear offline service cache
      await _clearOfflineCache();

      // Clear shared preferences cache (additional cleanup)
      await _clearSharedPreferencesCache();

      // Update last cleared timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_cache_clear', DateTime.now().toIso8601String());

      print('All caches cleared successfully');
    } catch (e) {
      print('Error clearing caches: $e');
    }
  }

  // Clear nearby services cache
  static Future<void> _clearNearbyCache() async {
    try {
      await NearbyCacheService.clearCache();
    } catch (e) {
      print('Error clearing nearby cache: $e');
    }
  }

  // Clear offline service cache
  static Future<void> _clearOfflineCache() async {
    try {
      await OfflineService.clearCache();
    } catch (e) {
      print('Error clearing offline cache: $e');
    }
  }

  // Clear additional shared preferences cache
  static Future<void> _clearSharedPreferencesCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear any additional cache keys that might exist
      final keys = prefs.getKeys();
      final cacheKeys = keys.where((key) =>
        key.contains('cache') ||
        key.contains('Cache') ||
        key.contains('_temp') ||
        key.contains('temp_')
      );

      for (final key in cacheKeys) {
        await prefs.remove(key);
      }
    } catch (e) {
      print('Error clearing shared preferences cache: $e');
    }
  }



  // Get cache status information
  static Future<Map<String, dynamic>> getCacheStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get cache keys count
      final keys = prefs.getKeys();
      final cacheKeys = keys.where((key) =>
        key.contains('cache') ||
        key.contains('Cache') ||
        key.contains('_temp') ||
        key.contains('temp_')
      ).length;

      // Get storage size estimate (rough calculation)
      int estimatedSize = 0;
      for (final key in keys) {
        final value = prefs.get(key);
        if (value is String) {
          estimatedSize += value.length * 2; // Rough UTF-16 estimate
        }
      }

      return {
        'cacheKeysCount': cacheKeys,
        'totalKeysCount': keys.length,
        'estimatedSizeKB': (estimatedSize / 1024).round(),
        'lastCleared': prefs.getString('last_cache_clear') ?? 'Never',
      };
    } catch (e) {
      print('Error getting cache status: $e');
      return {
        'cacheKeysCount': 0,
        'totalKeysCount': 0,
        'estimatedSizeKB': 0,
        'lastCleared': 'Unknown',
      };
    }
  }

  // ==================== CLEANUP ====================

  static Future<void> clearUserData() async {
    try {
      final settingsRef = await _getUserSettingsRef();
      if (settingsRef == null) return;

      await settingsRef.delete();
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }
}
