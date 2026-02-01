// import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import '../models/emergency_contact.dart';
import 'auth_service.dart';

class EmergencyContactService {
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

  // Save emergency contacts to Firestore (subcollection)
  Future<void> saveEmergencyContacts(List<EmergencyContact> contacts) async {
    final userId = await _getUserId();
    if (userId == null) return;

    try {
      final contactsJson = contacts
          .map((contact) => {
                'id': contact.id,
                'name': contact.name,
                'phoneNumber': contact.phoneNumber,
                'email': contact.email,
                'type': contact.type.toString(),
                'notes': contact.notes,
                'isPrimary': contact.isPrimary,
              })
          .toList();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('emergencyContacts')
          .doc('contacts')
          .set({'contacts': contactsJson});
    } catch (e) {
      throw Exception('Failed to save emergency contacts: $e');
    }
  }

  // Load emergency contacts from Firestore (subcollection and top-level collection)
  Future<List<EmergencyContact>> loadAllEmergencyContacts() async {
    final userId = await _getUserId();
    if (userId == null) return [];

    List<EmergencyContact> allContacts = [];

    try {
      // First, try loading from the subcollection (users/{userId}/emergencyContacts/contacts)
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('emergencyContacts')
          .doc('contacts')
          .get();

      if (doc.exists && doc.data() != null) {
        final contactsList = doc.data()!['contacts'] as List;
        allContacts = contactsList
            .map((item) => EmergencyContact(
                  id: item['id'],
                  name: item['name'],
                  phoneNumber: item['phoneNumber'],
                  email: item['email'],
                  type: EmergencyContactType.values.firstWhere(
                    (e) => e.toString() == item['type'],
                    orElse: () => EmergencyContactType.custom,
                  ),
                  notes: item['notes'],
                  isPrimary: item['isPrimary'] ?? false,
                ))
            .toList();
      }

      // If no contacts found in subcollection, also check the top-level emergencyContacts collection
      if (allContacts.isEmpty) {
        final existingContacts = await _firestore
            .collection('emergencyContacts')
            .where('userId', isEqualTo: userId)
            .get();

        if (existingContacts.docs.isNotEmpty) {
          allContacts = existingContacts.docs
              .map((doc) => EmergencyContact(
                    id: doc.id,
                    name: doc.data()['name'] ?? '',
                    phoneNumber: doc.data()['phoneNumber'] ?? '',
                    email: doc.data()['email'] ?? '',
                    type: EmergencyContactType.values.firstWhere(
                      (e) => e.toString() == doc.data()['type'],
                      orElse: () => EmergencyContactType.custom,
                    ),
                    notes: doc.data()['notes'] ?? '',
                    isPrimary: doc.data()['isPrimary'] ?? false,
                  ))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error loading emergency contacts: $e');
      // Return empty list instead of throwing exception
      return [];
    }
    return allContacts;
  }

  // Add a single emergency contact
  Future<void> addEmergencyContact(EmergencyContact contact) async {
    final contacts = await loadAllEmergencyContacts();
    contacts.add(contact);
    await saveEmergencyContacts(contacts);
  }

  // Remove an emergency contact by ID
  Future<void> removeEmergencyContact(String id) async {
    final contacts = await loadAllEmergencyContacts();
    contacts.removeWhere((contact) => contact.id == id);
    await saveEmergencyContacts(contacts);
  }

  // Update an emergency contact
  Future<void> updateEmergencyContact(EmergencyContact updatedContact) async {
    final contacts = await loadAllEmergencyContacts();
    final index =
        contacts.indexWhere((contact) => contact.id == updatedContact.id);
    if (index != -1) {
      contacts[index] = updatedContact;
      await saveEmergencyContacts(contacts);
    }
  }

  // Clear all emergency contacts
  Future<void> clearEmergencyContacts() async {
    final userId = await _getUserId();
    if (userId == null) return;

    try {
      final batch = _firestore.batch();

      // Delete all contacts for this user from top-level collection
      final existingContacts = await _firestore
          .collection('emergencyContacts')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in existingContacts.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear emergency contacts: $e');
    }
  }

  // Get default emergency contacts (for first-time users)
  static List<EmergencyContact> getDefaultContacts() {
    return [
      EmergencyContact(
        id: '1',
        name: 'Police',
        phoneNumber: '100',
        email: '',
        type: EmergencyContactType.police,
      ),
      EmergencyContact(
        id: '2',
        name: 'Ambulance',
        phoneNumber: '102',
        email: '',
        type: EmergencyContactType.ambulance,
      ),
      EmergencyContact(
        id: '3',
        name: 'Fire Department',
        phoneNumber: '101',
        email: '',
        type: EmergencyContactType.fire,
      ),
    ];
  }
}
