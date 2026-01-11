import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/emergency_contact.dart';

class EmergencyContactService {
  static const String _emergencyContactsKey = 'emergency_contacts';

  // Save emergency contacts to local storage
  static Future<void> saveEmergencyContacts(
      List<EmergencyContact> contacts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
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

      await prefs.setString(_emergencyContactsKey, json.encode(contactsJson));
    } catch (e) {
      throw Exception('Failed to save emergency contacts: $e');
    }
  }

  // Load emergency contacts from local storage
  static Future<List<EmergencyContact>> loadEmergencyContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getString(_emergencyContactsKey);

      if (contactsJson != null) {
        final contactsList = json.decode(contactsJson) as List;
        return contactsList
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
    } catch (e) {
      throw Exception('Failed to load emergency contacts: $e');
    }
    return [];
  }

  // Add a single emergency contact
  static Future<void> addEmergencyContact(EmergencyContact contact) async {
    final contacts = await loadEmergencyContacts();
    contacts.add(contact);
    await saveEmergencyContacts(contacts);
  }

  // Remove an emergency contact by ID
  static Future<void> removeEmergencyContact(String id) async {
    final contacts = await loadEmergencyContacts();
    contacts.removeWhere((contact) => contact.id == id);
    await saveEmergencyContacts(contacts);
  }

  // Update an emergency contact
  static Future<void> updateEmergencyContact(
      EmergencyContact updatedContact) async {
    final contacts = await loadEmergencyContacts();
    final index =
        contacts.indexWhere((contact) => contact.id == updatedContact.id);
    if (index != -1) {
      contacts[index] = updatedContact;
      await saveEmergencyContacts(contacts);
    }
  }

  // Clear all emergency contacts
  static Future<void> clearEmergencyContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_emergencyContactsKey);
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
