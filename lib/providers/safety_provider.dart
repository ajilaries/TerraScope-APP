import 'package:flutter/material.dart';
import '../models/saftey_status.dart';
import '../models/emergency_contact.dart';
import '../models/safety_alert.dart';
import '../Services/saftey_service.dart';
import '../Services/weather_services.dart';
import '../Services/location_service.dart';
import '../Services/emergency_contact_service.dart';
import '../Services/safety_history_service.dart';
import '../Services/fcm_service.dart';
import '../utils/safety_notification_manager.dart';
import 'dart:async';

final EmergencyContactService _emergencyContactService =
    EmergencyContactService();

class SafetyProvider extends ChangeNotifier {
  bool _isSafetyModeEnabled = false;
  SafetyStatus? _currentStatus;
  List<EmergencyContact> _emergencyContacts = [];
  List<SafetyAlert> _safetyHistory = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _safetyUpdateTimer;

  // Current weather data
  double? _currentRainMm;
  double? _currentWindSpeed;
  int? _currentVisibility;
  double? _currentTemperature;
  int? _currentHumidity;

  // Getters
  bool get isSafetyModeEnabled => _isSafetyModeEnabled;
  SafetyStatus? get currentStatus => _currentStatus;
  List<EmergencyContact> get emergencyContacts => _emergencyContacts;
  List<SafetyAlert> get safetyHistory => _safetyHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Weather data getters
  double? get currentRainMm => _currentRainMm;
  double? get currentWindSpeed => _currentWindSpeed;
  int? get currentVisibility => _currentVisibility;
  double? get currentTemperature => _currentTemperature;
  int? get currentHumidity => _currentHumidity;

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
      _startPeriodicSafetyUpdates();
      // Send FCM notification when safety mode is enabled
      await FCMService.sendTestNotification(
        title: 'Safety Mode Enabled',
        body: 'Real-time safety monitoring is now active. You will receive alerts for weather hazards.',
        type: 'safety_mode',
      );
    } else {
      _stopPeriodicSafetyUpdates();
    }
    notifyListeners();
  }

  // Check current safety status with real weather data
  Future<void> checkCurrentSafety({
    double? rainMm,
    double? windSpeed,
    int? visibility,
    double? temperature,
    int? humidity,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current location
      final position = await LocationService.getCurrentPosition();
      if (position == null) {
        throw Exception(
            'Unable to get current location. Please check location permissions.');
      }

      // Fetch real weather data
      final weatherData = await WeatherService.getCurrentWeather(
          position.latitude, position.longitude);
      if (weatherData == null) {
        throw Exception(
            'Unable to fetch weather data. Please check internet connection.');
      }

      // Parse weather data
      final parsedWeather = WeatherService.parseWeatherData(weatherData);

      // Use real weather data or fallback to provided/default values
      final actualRainMm =
          rainMm ?? (parsedWeather['rainMm'] as num).toDouble();
      final actualWindSpeed =
          windSpeed ?? (parsedWeather['windSpeed'] as num).toDouble();
      final actualVisibility =
          visibility ?? (parsedWeather['visibility'] as int);
      final actualTemperature =
          temperature ?? (parsedWeather['temperature'] as num).toDouble();
      final actualHumidity = humidity ?? (parsedWeather['humidity'] as int);

      // Store current weather data
      _currentRainMm = actualRainMm;
      _currentWindSpeed = actualWindSpeed;
      _currentVisibility = actualVisibility;
      _currentTemperature = actualTemperature;
      _currentHumidity = actualHumidity;

      _currentStatus = SafetyService.checkSafety(
        rainMm: actualRainMm,
        windSpeed: actualWindSpeed,
        visibility: actualVisibility,
        temperature: actualTemperature,
        humidity: actualHumidity,
      );

      // Add to history if safety mode is on
      if (_isSafetyModeEnabled && _currentStatus != null) {
        final alert = SafetyAlert(
          level: _currentStatus!.level,
          message: _currentStatus!.message,
          timestamp: DateTime.now(),
          rainMm: actualRainMm,
          windSpeed: actualWindSpeed,
          visibility: actualVisibility,
          temperature: actualTemperature,
          humidity: actualHumidity,
        );

        // Add to local list
        _safetyHistory.insert(0, alert);

        // Keep only last 50 records locally
        if (_safetyHistory.length > 50) {
          _safetyHistory.removeLast();
        }

        // Save to Firestore asynchronously (don't await to avoid blocking UI)
        _safetyHistoryService.addSafetyAlert(alert).catchError((e) {
          debugPrint('Failed to save safety alert to Firestore: $e');
        });
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
    try {
      // Add to Firestore
      await _emergencyContactService.addEmergencyContact(contact);
      _emergencyContacts.add(contact);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to add emergency contact: $e');
    }
  }

  // Remove emergency contact
  Future<void> removeEmergencyContact(String id) async {
    try {
      // Remove from Firestore
      await _emergencyContactService.removeEmergencyContact(id);
      _emergencyContacts.removeWhere((contact) => contact.id == id);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to remove emergency contact: $e');
    }
  }

  // Load emergency contacts
  Future<void> loadEmergencyContacts() async {
    try {
      // Load from Firestore
      final contacts = await _emergencyContactService.loadEmergencyContacts();

      if (contacts.isNotEmpty) {
        _emergencyContacts = contacts;
        debugPrint('Loaded ${contacts.length} emergency contacts from Firestore');
      } else {
        // No contacts saved, load default ones
        _emergencyContacts = EmergencyContactService.getDefaultContacts();
        // Save the default contacts to Firestore
        await _emergencyContactService.saveEmergencyContacts(_emergencyContacts);
        debugPrint('No saved contacts found, loaded default contacts');
      }
    } catch (e) {
      // Fallback to default contacts if loading fails
      _emergencyContacts = EmergencyContactService.getDefaultContacts();
      debugPrint('Failed to load emergency contacts from Firestore: $e');
    }
  }



  // Load safety history
  Future<void> loadSafetyHistory() async {
    try {
      // Load from Firestore
      final history = await _safetyHistoryService.loadSafetyHistory();
      _safetyHistory = history;
      debugPrint('Loaded ${history.length} safety history records from Firestore');
    } catch (e) {
      // Fallback to empty list if loading fails
      _safetyHistory = [];
      debugPrint('Failed to load safety history from Firestore: $e');
    }
  }

  // Clear history
  Future<void> clearSafetyHistory() async {
    _safetyHistory = [];
    notifyListeners();
  }

  // Start periodic safety updates (every 5 minutes)
  void _startPeriodicSafetyUpdates() {
    _stopPeriodicSafetyUpdates(); // Cancel any existing timer
    _safetyUpdateTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_isSafetyModeEnabled) {
        checkCurrentSafety();
      }
    });
  }

  // Stop periodic safety updates
  void _stopPeriodicSafetyUpdates() {
    _safetyUpdateTimer?.cancel();
    _safetyUpdateTimer = null;
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

  // Show safety alert with context
  void showSafetyAlert(BuildContext context) {
    if (_currentStatus != null && _isSafetyModeEnabled) {
      if (_currentStatus!.level == HazardLevel.danger) {
        SafetyNotificationManager.showEmergencyAlert(
          context,
          title: 'DANGER ALERT',
          message: _currentStatus!.message,
          warnings: _currentStatus!.warnings,
        );
      } else if (_currentStatus!.level == HazardLevel.caution) {
        SafetyNotificationManager.showWarning(
          context,
          _currentStatus!.message,
        );
      }
    }
  }

  // Dispose method to clean up resources
  @override
  void dispose() {
    _stopPeriodicSafetyUpdates();
    super.dispose();
  }
}
