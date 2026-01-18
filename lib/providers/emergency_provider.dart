import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/emergency_contact.dart';
import '../Services/auth_service.dart';

class EmergencyProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  String? _currentUserId;

  List<EmergencyContact> _contacts = [];
  bool _isSignupCompleted = false;

  // Get user-specific keys
  String get _contactsKey => 'emergency_contacts_${_currentUserId ?? 'guest'}';
  String get _signupCompletedKey =>
      'signup_completed_${_currentUserId ?? 'guest'}';

  List<EmergencyContact> get contacts => List.unmodifiable(_contacts);
  bool get isSignupCompleted => _isSignupCompleted;
  bool get hasContacts => _contacts.isNotEmpty;

  EmergencyContact? get primaryContact =>
      _contacts.isNotEmpty ? _contacts[0] : null;

  // Set current user for user-specific data
  Future<void> setCurrentUser() async {
    try {
      _currentUserId = await _authService.getSavedUserId();
      print('Emergency provider set for user: ${_currentUserId ?? 'guest'}');
    } catch (e) {
      print('Error setting current user for emergency provider: $e');
      _currentUserId = null;
    }
  }

  // Load data from storage
  Future<void> loadData() async {
    try {
      // Set current user first
      await setCurrentUser();

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

    final phoneUri = Uri.parse('tel:${contact.phoneNumber}');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw Exception('Cannot make phone call');
    }
  }

  // Send emergency SMS
  Future<void> sendEmergencySMS(String contactId, String message) async {
    final contact = _contacts.firstWhereOrNull((c) => c.id == contactId);
    if (contact == null) return;

    final smsUri = Uri.parse(
        'sms:${contact.phoneNumber}?body=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
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
