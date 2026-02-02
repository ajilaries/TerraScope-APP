import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/safety_alert.dart';
import '../models/saftey_status.dart';
import 'weather_services.dart';
import 'saftey_service.dart';

class OfflineService {
  static const String _weatherCacheKey = 'weather_cache';
  static const String _safetyHistoryKey = 'safety_history';
  static const String _lastLocationKey = 'last_location';
  static const String _cacheExpiryKey = 'cache_expiry';

  static const Duration _cacheDuration = Duration(hours: 6); // 6 hours cache

  // Check if device is online (simplified - always return true for now)
  // In a real implementation, you might use a package like connectivity_plus
  static Future<bool> isOnline() async {
    // For now, assume online. In production, implement proper connectivity check
    return true;
  }

  // Cache weather data for offline use
  static Future<void> cacheWeatherData(double lat, double lon) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get current weather data
      final weatherData = await WeatherService.getCurrentWeatherCached(lat, lon);

      if (weatherData != null) {
        final cacheData = {
          'weather': weatherData,
          'location': {'lat': lat, 'lon': lon},
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };

        await prefs.setString(_weatherCacheKey, json.encode(cacheData));
        await prefs.setInt(_cacheExpiryKey,
            DateTime.now().add(_cacheDuration).millisecondsSinceEpoch);
      }
    } catch (e) {
      print('Error caching weather data: $e');
    }
  }

  // Get cached weather data
  static Future<Map<String, dynamic>?> getCachedWeatherData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheExpiry = prefs.getInt(_cacheExpiryKey);

      if (cacheExpiry == null ||
          DateTime.now().millisecondsSinceEpoch > cacheExpiry) {
        return null; // Cache expired
      }

      final cachedData = prefs.getString(_weatherCacheKey);
      if (cachedData != null) {
        return json.decode(cachedData);
      }
    } catch (e) {
      print('Error retrieving cached weather data: $e');
    }
    return null;
  }

  // Perform offline safety assessment
  static Future<SafetyStatus?> performOfflineSafetyCheck() async {
    try {
      final cachedData = await getCachedWeatherData();
      if (cachedData == null) return null;

      final weatherData = cachedData['weather'];

      // Parse weather data for offline assessment
      final parsedWeather = WeatherService.parseWeatherData(weatherData);

      // Perform safety check with cached data
      return SafetyService.checkSafety(
        rainMm: parsedWeather['rainMm'],
        windSpeed: parsedWeather['windSpeed'],
        visibility: parsedWeather['visibility'],
        temperature: parsedWeather['temperature'],
        humidity: parsedWeather['humidity'],
      );
    } catch (e) {
      print('Error performing offline safety check: $e');
      return null;
    }
  }

  // Cache safety history
  static Future<void> cacheSafetyHistory(List<SafetyAlert> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = history
          .map((alert) => {
                'level': alert.level.toString(),
                'message': alert.message,
                'timestamp': alert.timestamp.millisecondsSinceEpoch,
                'rainMm': alert.rainMm,
                'windSpeed': alert.windSpeed,
                'visibility': alert.visibility,
                'temperature': alert.temperature,
              })
          .toList();

      await prefs.setString(_safetyHistoryKey, json.encode(historyJson));
    } catch (e) {
      print('Error caching safety history: $e');
    }
  }

  // Get cached safety history
  static Future<List<SafetyAlert>> getCachedSafetyHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_safetyHistoryKey);

      if (historyJson != null) {
        final historyList = json.decode(historyJson) as List;
        return historyList
            .map((item) => SafetyAlert(
                  level: HazardLevel.values.firstWhere(
                    (e) => e.toString() == item['level'],
                    orElse: () => HazardLevel.safe,
                  ),
                  message: item['message'],
                  timestamp:
                      DateTime.fromMillisecondsSinceEpoch(item['timestamp']),
                  rainMm: item['rainMm']?.toDouble() ?? 0.0,
                  windSpeed: item['windSpeed']?.toDouble() ?? 0.0,
                  visibility: item['visibility'] ?? 10000,
                  temperature: item['temperature']?.toDouble() ?? 25.0,
                ))
            .toList();
      }
    } catch (e) {
      print('Error retrieving cached safety history: $e');
    }
    return [];
  }

  // Cache last known location
  static Future<void> cacheLastLocation(double lat, double lon) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _lastLocationKey,
          json.encode({
            'lat': lat,
            'lon': lon,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          }));
    } catch (e) {
      print('Error caching location: $e');
    }
  }

  // Get cached location
  static Future<Map<String, double>?> getCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson = prefs.getString(_lastLocationKey);

      if (locationJson != null) {
        final locationData = json.decode(locationJson);
        return {
          'lat': locationData['lat'].toDouble(),
          'lon': locationData['lon'].toDouble(),
        };
      }
    } catch (e) {
      print('Error retrieving cached location: $e');
    }
    return null;
  }

  // Clear all cached data
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_weatherCacheKey);
      await prefs.remove(_safetyHistoryKey);
      await prefs.remove(_lastLocationKey);
      await prefs.remove(_cacheExpiryKey);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Get cache status
  static Future<Map<String, dynamic>> getCacheStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheExpiry = prefs.getInt(_cacheExpiryKey);
    final hasWeatherCache = prefs.containsKey(_weatherCacheKey);
    final hasHistoryCache = prefs.containsKey(_safetyHistoryKey);

    return {
      'hasWeatherCache': hasWeatherCache,
      'hasHistoryCache': hasHistoryCache,
      'cacheExpiry': cacheExpiry != null
          ? DateTime.fromMillisecondsSinceEpoch(cacheExpiry)
          : null,
      'isExpired': cacheExpiry == null ||
          DateTime.now().millisecondsSinceEpoch > cacheExpiry,
    };
  }
}
