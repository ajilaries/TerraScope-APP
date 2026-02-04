import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'weather_services.dart';
import 'fcm_service.dart';
import '../utils/safety_utils.dart';

class AnomalyMonitoringService {
  static const String _taskName = 'anomaly_monitoring_task';
  static const String _lastCheckKey = 'last_anomaly_check';
  static const String _userLocationKey = 'user_location';
  static const String _monitoringEnabledKey = 'anomaly_monitoring_enabled';
  static const Duration _checkInterval = Duration(minutes: 15); // Check every 15 minutes

  // Initialize background anomaly monitoring
  static Future<void> initialize() async {
    // Register the background task
    Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: _checkInterval,
      initialDelay: const Duration(minutes: 5), // Start after 5 minutes
      constraints: Constraints(
        networkType: NetworkType.connected, // Only run when network is available
      ),
    );

    print('Anomaly monitoring service initialized');
  }

  // Enable/disable anomaly monitoring
  static Future<void> setMonitoringEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_monitoringEnabledKey, enabled);

    if (enabled) {
      await initialize();
    } else {
      await Workmanager().cancelByUniqueName(_taskName);
    }
  }

  // Check if monitoring is enabled
  static Future<bool> isMonitoringEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_monitoringEnabledKey) ?? false;
  }

  // Update user location for monitoring
  static Future<void> updateUserLocation(double lat, double lon) async {
    final prefs = await SharedPreferences.getInstance();
    final locationData = {'lat': lat, 'lon': lon, 'timestamp': DateTime.now().millisecondsSinceEpoch};
    await prefs.setString(_userLocationKey, json.encode(locationData));
  }

  // Background task callback
  static Future<void> callbackDispatcher() async {
    Workmanager().executeTask((task, inputData) async {
      try {
        print('Anomaly monitoring task started');

        // Check if monitoring is enabled
        final enabled = await isMonitoringEnabled();
        if (!enabled) {
          print('Anomaly monitoring is disabled');
          return true;
        }

        // Check if enough time has passed since last check
        final prefs = await SharedPreferences.getInstance();
        final lastCheck = prefs.getInt(_lastCheckKey) ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;
        final timeSinceLastCheck = now - lastCheck;

        if (timeSinceLastCheck < _checkInterval.inMilliseconds) {
          print('Too soon since last check');
          return true;
        }

        // Get user location
        final locationString = prefs.getString(_userLocationKey);
        if (locationString == null) {
          print('No user location available');
          return true;
        }

        final locationData = json.decode(locationString) as Map<String, dynamic>;
        final lat = locationData['lat'] as double;
        final lon = locationData['lon'] as double;

        // Check for anomalies
        await _checkForAnomalies(lat, lon);

        // Update last check timestamp
        await prefs.setInt(_lastCheckKey, now);

        print('Anomaly monitoring task completed successfully');
        return true;
      } catch (e) {
        print('Error in anomaly monitoring task: $e');
        return false;
      }
    });
  }

  // Check for weather anomalies and send notifications
  static Future<void> _checkForAnomalies(double lat, double lon) async {
    try {
      // Get current weather anomalies
      final anomalies = await WeatherService.getAnomalies(lat, lon);

      if (anomalies.isNotEmpty) {
        // Check if these are new anomalies (not already notified)
        final newAnomalies = await _filterNewAnomalies(anomalies);

        for (final anomaly in newAnomalies) {
          await _sendAnomalyNotification(anomaly);
          await _saveNotifiedAnomaly(anomaly);
        }
      }

      // Also check for severe weather conditions
      final weatherData = await WeatherService.getCurrentWeather(lat, lon);
      if (weatherData != null) {
        final severeConditions = _detectSevereConditions(weatherData);
        for (final condition in severeConditions) {
          await _sendSevereWeatherNotification(condition);
        }
      }
    } catch (e) {
      print('Error checking for anomalies: $e');
    }
  }

  // Filter out anomalies that have already been notified
  static Future<List<Map<String, dynamic>>> _filterNewAnomalies(
      List<Map<String, dynamic>> anomalies) async {
    final prefs = await SharedPreferences.getInstance();
    final notifiedAnomalies = prefs.getStringList('notified_anomalies') ?? [];

    return anomalies.where((anomaly) {
      final anomalyKey = _generateAnomalyKey(anomaly);
      return !notifiedAnomalies.contains(anomalyKey);
    }).toList();
  }

  // Save notified anomaly to prevent duplicate notifications
  static Future<void> _saveNotifiedAnomaly(Map<String, dynamic> anomaly) async {
    final prefs = await SharedPreferences.getInstance();
    final notifiedAnomalies = prefs.getStringList('notified_anomalies') ?? [];
    final anomalyKey = _generateAnomalyKey(anomaly);

    notifiedAnomalies.add(anomalyKey);

    // Keep only last 50 notifications to prevent list from growing too large
    if (notifiedAnomalies.length > 50) {
      notifiedAnomalies.removeRange(0, notifiedAnomalies.length - 50);
    }

    await prefs.setStringList('notified_anomalies', notifiedAnomalies);
  }

  // Generate unique key for anomaly
  static String _generateAnomalyKey(Map<String, dynamic> anomaly) {
    final type = anomaly['type'] ?? 'unknown';
    final time = anomaly['time'] ?? DateTime.now().toString();
    return '$type|$time';
  }

  // Send notification for weather anomaly
  static Future<void> _sendAnomalyNotification(Map<String, dynamic> anomaly) async {
    final title = 'Weather Alert';
    final body = '${anomaly['type']}: ${anomaly['forecast']}';

    // Note: FCM notifications are now handled server-side
    // Use Firebase Admin SDK or Cloud Functions to send notifications
    // await FCMService.sendTestNotification(
    //   title: title,
    //   body: body,
    //   type: 'weather_alert',
    // );

    print('Anomaly detected: $title - $body (notification would be sent via FCM server)');
  }

  // Detect severe weather conditions from current weather data
  static List<Map<String, dynamic>> _detectSevereConditions(Map<String, dynamic> weatherData) {
    final conditions = <Map<String, dynamic>>[];
    final main = weatherData['main'] ?? {};
    final wind = weatherData['wind'] ?? {};
    final rain = weatherData['rain'] ?? {};

    final temp = (main['temp'] as num?)?.toDouble() ?? 0.0;
    final windSpeed = (wind['speed'] as num?)?.toDouble() ?? 0.0;
    final rainAmount = (rain['1h'] as num?)?.toDouble() ?? 0.0;

    // Extreme heat warning
    if (temp > 40) {
      conditions.add({
        'type': 'Extreme Heat Warning',
        'description': 'Temperature is extremely high (${temp.toStringAsFixed(1)}°C). Stay hydrated and avoid outdoor activities.',
        'severity': 'high',
      });
    }
    // Extreme cold warning
    else if (temp < -10) {
      conditions.add({
        'type': 'Extreme Cold Warning',
        'description': 'Temperature is extremely low (${temp.toStringAsFixed(1)}°C). Take precautions against frostbite.',
        'severity': 'high',
      });
    }

    // High wind warning
    if (windSpeed > 25) {
      conditions.add({
        'type': 'High Wind Warning',
        'description': 'Strong winds detected (${windSpeed.toStringAsFixed(1)} km/h). Secure loose objects.',
        'severity': 'moderate',
      });
    }

    // Heavy rain warning
    if (rainAmount > 15) {
      conditions.add({
        'type': 'Heavy Rain Warning',
        'description': 'Heavy rainfall detected (${rainAmount.toStringAsFixed(1)} mm/h). Be cautious of flooding.',
        'severity': 'moderate',
      });
    }

    return conditions;
  }

  // Send notification for severe weather condition
  static Future<void> _sendSevereWeatherNotification(Map<String, dynamic> condition) async {
    final title = condition['type'];
    final body = condition['description'];

    // Note: FCM notifications are now handled server-side
    // Use Firebase Admin SDK or Cloud Functions to send notifications
    // await FCMService.sendTestNotification(
    //   title: title,
    //   body: body,
    //   type: 'weather_alert',
    // );

    print('Severe weather detected: $title - $body (notification would be sent via FCM server)');
  }

  // Get monitoring status
  static Future<Map<String, dynamic>> getMonitoringStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = await isMonitoringEnabled();
    final lastCheck = prefs.getInt(_lastCheckKey) ?? 0;
    final locationString = prefs.getString(_userLocationKey);

    Map<String, dynamic>? location;
    if (locationString != null) {
      location = json.decode(locationString) as Map<String, dynamic>;
    }

    return {
      'enabled': enabled,
      'lastCheck': lastCheck,
      'location': location,
    };
  }

  // Clear all stored anomaly data (for testing/debugging)
  static Future<void> clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notified_anomalies');
    await prefs.remove(_lastCheckKey);
    await prefs.remove(_userLocationKey);
    await prefs.remove(_monitoringEnabledKey);
  }
}
