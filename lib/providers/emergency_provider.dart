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
  }
}
