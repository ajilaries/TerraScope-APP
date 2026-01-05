import 'package:flutter/material.dart';
import '../models/saftey_status.dart';
import '../models/emergency_contact.dart';
import '../models/safety_alert.dart';
import '../Services/saftey_service.dart';
import '../Services/weather_services.dart';
import '../Services/location_service.dart';
import 'dart:async';

class SafetyProvider extends ChangeNotifier {
  bool _isSafetyModeEnabled = false;
  SafetyStatus? _currentStatus;
  List<EmergencyContact> _emergencyContacts = [];
  List<SafetyAlert> _safetyHistory = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _safetyUpdateTimer;

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
      _startPeriodicSafetyUpdates();
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

      _currentStatus = SafetyService.checkSafety(
        rainMm: actualRainMm,
        windSpeed: actualWindSpeed,
        visibility: actualVisibility,
        temperature: actualTemperature,
        humidity: actualHumidity,
      );

      // Add to history if safety mode is on
      if (_isSafetyModeEnabled && _currentStatus != null) {
        _safetyHistory.insert(
          0,
          SafetyAlert(
            level: _currentStatus!.level,
            message: _currentStatus!.message,
            timestamp: DateTime.now(),
            rainMm: actualRainMm,
            windSpeed: actualWindSpeed,
            visibility: actualVisibility,
            temperature: actualTemperature,
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

  // Dispose method to clean up resources
  @override
  void dispose() {
    _stopPeriodicSafetyUpdates();
    super.dispose();
  }
}
