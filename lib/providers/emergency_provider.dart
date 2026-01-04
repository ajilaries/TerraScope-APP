import 'package:flutter/material.dart';
import '../models/emergency_contact.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyProvider extends ChangeNotifier {
  List<EmergencyContact> _contacts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<EmergencyContact> get contacts => _contacts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  EmergencyContact? get primaryContact {
    try {
      return _contacts.firstWhere((contact) => contact.isPrimary == true);
    } catch (e) {
      return null;
    }
  }

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getStringList('emergency_contacts') ?? [];

      _contacts = contactsJson.map((json) {
        // Parse JSON string back to EmergencyContact
        // For now, using dummy data as parsing is complex
        return EmergencyContact(
          id: '1',
          name: 'Police',
          phoneNumber: '100',
          email: '',
          type: EmergencyContactType.police,
        );
      }).toList();

      // If no contacts, load defaults
      if (_contacts.isEmpty) {
        _contacts = [
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
        await _saveContacts();
      }

      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> addContact(EmergencyContact contact) async {
    _contacts.add(contact);
    await _saveContacts();
    notifyListeners();
  }

  Future<void> updateContact(String id, EmergencyContact updatedContact) async {
    final index = _contacts.indexWhere((contact) => contact.id == id);
    if (index != -1) {
      _contacts[index] = updatedContact;
      await _saveContacts();
      notifyListeners();
    }
  }

  Future<void> removeContact(String id) async {
    _contacts.removeWhere((contact) => contact.id == id);
    await _saveContacts();
    notifyListeners();
  }

  Future<void> setPrimaryContact(String id) async {
    for (var contact in _contacts) {
      contact.isPrimary = contact.id == id;
    }
    await _saveContacts();
    notifyListeners();
  }

  Future<void> callContact(String id) async {
    final contact = _contacts.firstWhere((c) => c.id == id);
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: contact.phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> sendEmergencySMS(String id, String message) async {
    final contact = _contacts.firstWhere((c) => c.id == id);
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: contact.phoneNumber,
      queryParameters: {'body': message},
    );
    await launchUrl(launchUri);
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    // For now, just save a simple list. In production, serialize properly
    final contactsJson = _contacts.map((contact) => contact.name).toList();
    await prefs.setStringList('emergency_contacts', contactsJson);
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/emergency_contact.dart';

class EmergencyProvider with ChangeNotifier {
  static const String _contactsKey = 'emergency_contacts';
  static const String _signupCompletedKey = 'signup_completed';

  List<EmergencyContact> _contacts = [];
  bool _isSignupCompleted = false;

  List<EmergencyContact> get contacts => List.unmodifiable(_contacts);
  bool get isSignupCompleted => _isSignupCompleted;
  bool get hasContacts => _contacts.isNotEmpty;

  EmergencyContact? get primaryContact =>
      _contacts.isNotEmpty ? _contacts[0] : null;

  // Load data from storage
  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load signup status
      _isSignupCompleted = prefs.getBool(_signupCompletedKey) ?? false;

      // Load contacts
      final contactsJson = prefs.getString(_contactsKey);
      if (contactsJson != null) {
        final contactsList = json.decode(contactsJson) as List;
        _contacts = contactsList.map((contactJson) {
          return EmergencyContact(
            id: contactJson['id'],
            name: contactJson['name'],
            phoneNumber: contactJson['phoneNumber'],
            email: contactJson['email'] ?? '',
            type: EmergencyContactType.values.firstWhere(
              (e) => e.toString() == contactJson['type'],
              orElse: () => EmergencyContactType.custom,
            ),
          );
        }).toList();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading emergency data: $e');
    }
  }

  // Save data to storage
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save contacts
      final contactsJson = json.encode(_contacts
          .map((c) => {
                'id': c.id,
                'name': c.name,
                'phoneNumber': c.phoneNumber,
                'email': c.email,
                'type': c.type.toString(),
              })
          .toList());
      await prefs.setString(_contactsKey, contactsJson);

      // Save signup status
      await prefs.setBool(_signupCompletedKey, _isSignupCompleted);
    } catch (e) {
      debugPrint('Error saving emergency data: $e');
    }
  }

  // Complete signup with initial contacts
  Future<void> completeSignup(List<EmergencyContact> initialContacts) async {
    _contacts = List.from(initialContacts);
    _isSignupCompleted = true;
    await _saveData();
    notifyListeners();
  }

  // Add emergency contact
  Future<void> addContact(EmergencyContact contact) async {
    // Check for duplicate phone numbers
    if (_contacts.any((c) => c.phoneNumber == contact.phoneNumber)) {
      throw Exception('Contact with this phone number already exists');
    }

    _contacts.add(contact);
    await _saveData();
    notifyListeners();
  }

  // Update emergency contact
  Future<void> updateContact(
      String contactId, EmergencyContact updatedContact) async {
    final index = _contacts.indexWhere((c) => c.id == contactId);
    if (index == -1) {
      throw Exception('Contact not found');
    }

    // Check for duplicate phone numbers (excluding current contact)
    if (_contacts.any((c) =>
        c.id != contactId && c.phoneNumber == updatedContact.phoneNumber)) {
      throw Exception('Contact with this phone number already exists');
    }

    _contacts[index] = updatedContact;
    await _saveData();
    notifyListeners();
  }

  // Remove emergency contact
  Future<void> removeContact(String contactId) async {
    _contacts.removeWhere((c) => c.id == contactId);
    await _saveData();
    notifyListeners();
  }

  // Reorder contacts (move contact to front as primary)
  Future<void> setPrimaryContact(String contactId) async {
    final contactIndex = _contacts.indexWhere((c) => c.id == contactId);
    if (contactIndex > 0) {
      final contact = _contacts.removeAt(contactIndex);
      _contacts.insert(0, contact);
      await _saveData();
      notifyListeners();
    }
  }

  // Call emergency contact
  Future<void> callContact(String contactId) async {
    final contact = _contacts.firstWhereOrNull((c) => c.id == contactId);
    if (contact == null) return;

    final phoneUrl = 'tel:${contact.phoneNumber}';
    if (await canLaunch(phoneUrl)) {
      await launch(phoneUrl);
    } else {
      throw Exception('Cannot make phone call');
    }
  }

  // Send emergency SMS
  Future<void> sendEmergencySMS(String contactId, String message) async {
    final contact = _contacts.firstWhereOrNull((c) => c.id == contactId);
    if (contact == null) return;

    final smsUrl =
        'sms:${contact.phoneNumber}?body=${Uri.encodeComponent(message)}';
    if (await canLaunch(smsUrl)) {
      await launch(smsUrl);
    } else {
      throw Exception('Cannot send SMS');
    }
  }

  // Send emergency alert to all contacts
  Future<void> sendEmergencyAlert(String alertMessage) async {
    if (_contacts.isEmpty) return;

    final emergencyMessage =
        '🚨 EMERGENCY ALERT 🚨\n\n$alertMessage\n\nSent from TerraScope Safety Mode';

    for (final contact in _contacts) {
      try {
        await sendEmergencySMS(contact.id, emergencyMessage);
      } catch (e) {
        debugPrint('Failed to send alert to ${contact.name}: $e');
      }
    }
  }

  // Validate phone number format
  bool isValidPhoneNumber(String phoneNumber) {
    // Basic phone number validation (adjust regex as needed for your region)
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    return phoneRegex.hasMatch(phoneNumber.replaceAll(RegExp(r'\s+'), ''));
  }

  // Get contact by ID
  EmergencyContact? getContactById(String contactId) {
    return _contacts.firstWhereOrNull((c) => c.id == contactId);
  }

  // Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    _contacts.clear();
    _isSignupCompleted = false;
    await _saveData();
    notifyListeners();
  }
}

// Extension for firstWhereOrNull
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
