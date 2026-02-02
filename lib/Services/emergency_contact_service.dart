import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import '../models/emergency_contact.dart';
import 'auth_service.dart';

class EmergencyContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<String?> _getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  // Save emergency contacts to Firestore (each contact as separate document)
  Future<void> saveEmergencyContacts(List<EmergencyContact> contacts) async {
    final userId = await _getUserId();
    if (userId == null) return;

    try {
      final batch = _firestore.batch();
      final userContactsRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('emergencyContacts');

      // Delete existing contacts
      final existingContacts = await userContactsRef.get();
      for (final doc in existingContacts.docs) {
        batch.delete(doc.reference);
      }

      // Add all contacts as separate documents
      for (final contact in contacts) {
        final contactRef = userContactsRef.doc(contact.id);
        batch.set(contactRef, {
          'id': contact.id,
          'name': contact.name,
          'phoneNumber': contact.phoneNumber,
          'email': contact.email,
          'type': contact.type.toString(),
          'notes': contact.notes,
          'isPrimary': contact.isPrimary,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to save emergency contacts: $e');
    }
  }

  // Load emergency contacts from Firestore (each contact as separate document)
  Future<List<EmergencyContact>> loadAllEmergencyContacts() async {
    final userId = await _getUserId();
    if (userId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('emergencyContacts')
          .get();

      final allContacts = snapshot.docs.map((doc) {
        final data = doc.data();
        return EmergencyContact(
          id: doc.id,
          name: data['name'] ?? '',
          phoneNumber: data['phoneNumber'] ?? '',
          email: data['email'] ?? '',
          type: EmergencyContactType.values.firstWhere(
            (e) => e.toString() == data['type'],
            orElse: () => EmergencyContactType.custom,
          ),
          notes: data['notes'] ?? '',
          isPrimary: data['isPrimary'] ?? false,
        );
      }).toList();

      // Sort by creation time if available, otherwise by name
      allContacts.sort((a, b) {
        // If both have timestamps, sort by timestamp
        // For now, sort by name as fallback
        return a.name.compareTo(b.name);
      });

      return allContacts;
    } catch (e) {
      debugPrint('Error loading emergency contacts: $e');
      // Return empty list instead of throwing exception
      return [];
    }
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
