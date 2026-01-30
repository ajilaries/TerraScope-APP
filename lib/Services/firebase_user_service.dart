import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class FirebaseUserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final AuthService _authService = AuthService();

  // Get current user ID from Firebase Auth
  static Future<String?> _getCurrentUserId() async {
    final user = _auth.currentUser;
    return user?.uid;
  }

  // ==================== USER PROFILE ====================

  static Future<void> createUserProfile({
    required String userId,
    required String name,
    required String email,
    required String gender,
    required String userMode,
    required int age,
    required String phoneNumber,
    required String address,
    List<Map<String, dynamic>>? emergencyContacts,
    bool? enableNotifications,
    bool? enableLocationSharing,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'userId': userId,
        'name': name,
        'email': email,
        'gender': gender,
        'userMode': userMode,
        'age': age,
        'phoneNumber': phoneNumber,
        'address': address,
        'emergencyContacts': emergencyContacts ?? [],
        'preferences': {
          'enableNotifications': enableNotifications ?? true,
          'enableLocationSharing': enableLocationSharing ?? true,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user profile: $e');
      throw e;
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return null;

      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;

      return doc.data();
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  static Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      updates['lastUpdated'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      print('Error updating user profile: $e');
      throw e;
    }
  }

  // ==================== WEATHER DATA ====================

  static Future<void> saveWeatherData(Map<String, dynamic> weatherData) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('weather')
          .doc('current')
          .set({
        ...weatherData,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving weather data: $e');
    }
  }

  static Future<Map<String, dynamic>?> getWeatherData() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weather')
          .doc('current')
          .get();

      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      print('Error getting weather data: $e');
      return null;
    }
  }

  // ==================== HEALTH REMINDERS ====================

  static Future<void> saveHealthReminders(
      List<Map<String, dynamic>> reminders) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      final batch = _firestore.batch();

      // Delete existing reminders
      final existingReminders = await _firestore
          .collection('users')
          .doc(userId)
          .collection('health_reminders')
          .get();

      for (final doc in existingReminders.docs) {
        batch.delete(doc.reference);
      }

      // Add new reminders
      for (final reminder in reminders) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('health_reminders')
            .doc();
        batch.set(docRef, {
          ...reminder,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error saving health reminders: $e');
      throw e;
    }
  }

  static Future<List<Map<String, dynamic>>> getHealthReminders() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('health_reminders')
          .orderBy('createdAt')
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting health reminders: $e');
      return [];
    }
  }

  static Future<void> updateHealthReminder(
      String reminderId, Map<String, dynamic> updates) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('health_reminders')
          .doc(reminderId)
          .update(updates);
    } catch (e) {
      print('Error updating health reminder: $e');
      throw e;
    }
  }

  // ==================== DAILY ACTIVITIES ====================

  static Future<void> saveDailyActivities(
      String date, List<Map<String, dynamic>> activities) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      final batch = _firestore.batch();

      // Delete existing activities for this date
      final existingActivities = await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_activities')
          .where('date', isEqualTo: date)
          .get();

      for (final doc in existingActivities.docs) {
        batch.delete(doc.reference);
      }

      // Add new activities
      for (final activity in activities) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('daily_activities')
            .doc();
        batch.set(docRef, {
          ...activity,
          'date': date,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error saving daily activities: $e');
      throw e;
    }
  }

  static Future<List<Map<String, dynamic>>> getDailyActivities(
      String date) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_activities')
          .where('date', isEqualTo: date)
          .orderBy('createdAt')
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting daily activities: $e');
      return [];
    }
  }

  // ==================== MEDICATIONS ====================

  static Future<void> saveMedications(
      List<Map<String, dynamic>> medications) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      final batch = _firestore.batch();

      // Delete existing medications
      final existingMeds = await _firestore
          .collection('users')
          .doc(userId)
          .collection('medications')
          .get();

      for (final doc in existingMeds.docs) {
        batch.delete(doc.reference);
      }

      // Add new medications
      for (final medication in medications) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('medications')
            .doc();
        batch.set(docRef, {
          ...medication,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error saving medications: $e');
      throw e;
    }
  }

  static Future<List<Map<String, dynamic>>> getMedications() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('medications')
          .orderBy('createdAt')
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting medications: $e');
      return [];
    }
  }

  // ==================== EMERGENCY CONTACTS ====================

  static Future<void> saveEmergencyContacts(
      List<Map<String, dynamic>> contacts) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      final batch = _firestore.batch();

      // Delete existing contacts
      final existingContacts = await _firestore
          .collection('users')
          .doc(userId)
          .collection('emergency_contacts')
          .get();

      for (final doc in existingContacts.docs) {
        batch.delete(doc.reference);
      }

      // Add new contacts
      for (final contact in contacts) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('emergency_contacts')
            .doc();
        batch.set(docRef, {
          ...contact,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error saving emergency contacts: $e');
      throw e;
    }
  }

  static Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('emergency_contacts')
          .orderBy('createdAt')
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting emergency contacts: $e');
      return [];
    }
  }

  // ==================== LOCATION HISTORY ====================

  static Future<void> saveLocationData(
      Map<String, dynamic> locationData) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('location_history')
          .add({
        ...locationData,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving location data: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getLocationHistory(
      {int limit = 50}) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('location_history')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting location history: $e');
      return [];
    }
  }

  // ==================== USER PREFERENCES ====================

  static Future<void> updateUserPreferences(
      Map<String, dynamic> preferences) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      await _firestore.collection('users').doc(userId).update({
        'preferences': preferences,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user preferences: $e');
      throw e;
    }
  }

  static Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return {};

      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return {};

      final data = doc.data();
      return data?['preferences'] as Map<String, dynamic>? ?? {};
    } catch (e) {
      print('Error getting user preferences: $e');
      return {};
    }
  }

  // ==================== SYNC STATUS ====================

  static Future<void> updateSyncStatus(
      String feature, DateTime lastSync) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      final syncData = {
        'feature': feature,
        'lastSync': lastSync.toIso8601String(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('sync_status')
          .doc(feature)
          .set(syncData);
    } catch (e) {
      print('Error updating sync status: $e');
    }
  }

  static Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return {};

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('sync_status')
          .get();

      final syncStatus = <String, dynamic>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        syncStatus[data['feature']] = data['lastSync'];
      }

      return syncStatus;
    } catch (e) {
      print('Error getting sync status: $e');
      return {};
    }
  }

  // ==================== DATA EXPORT/IMPORT ====================

  static Future<Map<String, dynamic>> exportUserData() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return {};

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return {};

      final exportData = {
        'profile': userDoc.data(),
        'health_reminders': await getHealthReminders(),
        'medications': await getMedications(),
        'emergency_contacts': await getEmergencyContacts(),
        'weather_data': await getWeatherData(),
        'preferences': await getUserPreferences(),
        'sync_status': await getSyncStatus(),
        'exported_at': FieldValue.serverTimestamp(),
      };

      return exportData;
    } catch (e) {
      print('Error exporting user data: $e');
      return {};
    }
  }

  // ==================== CLEANUP ====================

  static Future<void> deleteUserData() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      // Delete all subcollections first
      final collections = [
        'health_reminders',
        'daily_activities',
        'medications',
        'emergency_contacts',
        'location_history',
        'weather',
        'sync_status'
      ];

      for (final collection in collections) {
        final snapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection(collection)
            .get();

        final batch = _firestore.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      // Delete main user document
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      print('Error deleting user data: $e');
      throw e;
    }
  }

  // ==================== REAL-TIME LISTENERS ====================

  static Stream<DocumentSnapshot> getUserProfileStream() {
    final userId = _authService.getSavedUserId();
    return _firestore.collection('users').doc(userId as String?).snapshots();
  }

  static Stream<QuerySnapshot> getHealthRemindersStream() {
    final userId = _authService.getSavedUserId();
    return _firestore
        .collection('users')
        .doc(userId as String?)
        .collection('health_reminders')
        .orderBy('createdAt')
        .snapshots();
  }

  static Stream<QuerySnapshot> getEmergencyContactsStream() {
    final userId = _authService.getSavedUserId();
    return _firestore
        .collection('users')
        .doc(userId as String?)
        .collection('emergency_contacts')
        .orderBy('createdAt')
        .snapshots();
  }
}
