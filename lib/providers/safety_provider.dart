import 'package:flutter/material.dart';
import '../models/saftey_status.dart';
import '../models/emergency_contact.dart';
import '../models/safety_alert.dart';
import '../Services/saftey_service.dart';

class SafetyProvider extends ChangeNotifier {
  bool _isSafetyModeEnabled = false;
  SafetyStatus? _currentStatus;
  List<EmergencyContact> _emergencyContacts = [];
  List<SafetyAlert> _safetyHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isSafetyModeEnabled => _isSafetyModeEnabled;
  SafetyStatus? get currentStatus => _currentStatus;
  List<EmergencyContact> get emergencyContacts => _emergencyContacts;
  List<SafetyAlert> get safetyHistory => _safetyHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize provider
  Future<void> initializeSafetyMode() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await loadEmergencyContacts();
      await loadSafetyHistory();
      await checkCurrentSafety();
      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  // Toggle safety mode
  Future<void> toggleSafetyMode(bool value) async {
    _isSafetyModeEnabled = value;
    if (value) {
      await checkCurrentSafety();
    }
    notifyListeners();
  }

  // Check current safety status
  Future<void> checkCurrentSafety({
    double rainMm = 0,
    double windSpeed = 0,
    int visibility = 1000,
    double temperature = 25,
    int humidity = 60,
  }) async {
    _isLoading = true;
    try {
      _currentStatus = SafetyService.checkSafety(
        rainMm: rainMm,
        windSpeed: windSpeed,
        visibility: visibility,
        temperature: temperature,
        humidity: humidity,
      );

      // Add to history if safety mode is on
      if (_isSafetyModeEnabled && _currentStatus != null) {
        _safetyHistory.insert(
          0,
          SafetyAlert(
            level: _currentStatus!.level,
            message: _currentStatus!.message,
            timestamp: DateTime.now(),
            rainMm: rainMm,
            windSpeed: windSpeed,
            visibility: visibility,
            temperature: temperature,
          ),
        );

        // Keep only last 50 records
        if (_safetyHistory.length > 50) {
          _safetyHistory.removeLast();
        }
      }

      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  // Add emergency contact
  Future<void> addEmergencyContact(EmergencyContact contact) async {
    _emergencyContacts.add(contact);
    notifyListeners();
  }

  // Remove emergency contact
  Future<void> removeEmergencyContact(String id) async {
    _emergencyContacts.removeWhere((contact) => contact.id == id);
    notifyListeners();
  }

  // Load emergency contacts
  Future<void> loadEmergencyContacts() async {
    // TODO: Load from local storage or API
    _emergencyContacts = [
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

  // Load safety history
  Future<void> loadSafetyHistory() async {
    // TODO: Load from local storage
    // For now, initialize as empty
    _safetyHistory = [];
  }

  // Clear history
  Future<void> clearSafetyHistory() async {
    _safetyHistory = [];
    notifyListeners();
  }

  // Get safety score (0-100)
  int getSafetyScore() {
    if (_currentStatus == null) return 100;

    switch (_currentStatus!.level) {
      case HazardLevel.safe:
        return 100;
      case HazardLevel.caution:
        return 60;
      case HazardLevel.danger:
        return 20;
    }
  }
}
