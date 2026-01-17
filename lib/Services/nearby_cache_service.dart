import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'nearby_services.dart';
import 'auth_service.dart';

class NearbyCacheService {
  static const String _cacheKey = 'nearby_services_cache';
  static const String _locationKey = 'cached_location';
  static const String _timestampKey = 'cache_timestamp';
  static const Duration _cacheValidity =
      Duration(hours: 6); // Cache for 6 hours

  // Current user ID for user-specific caching
  static String? _currentUserId;

  // Cache structure: Map<serviceType, List<Map<String, dynamic>>>
  static Map<String, dynamic> _cachedData = {};
  static Map<String, double>? _cachedLocation;
  static DateTime? _cacheTimestamp;

  // Service types to preload
  static const List<String> _serviceTypes = [
    'hospital',
    'pharmacy',
    'clinic',
    'emergency room',
    'medical center',
    'urgent care',
  ];

  // Set current user for user-specific caching
  static Future<void> setCurrentUser() async {
    try {
      final authService = AuthService();
      _currentUserId = await authService.getSavedUserId();
      print('Nearby cache set for user: ${_currentUserId ?? 'guest'}');
    } catch (e) {
      print('Error setting current user for cache: $e');
      _currentUserId = null;
    }
  }

  // Initialize cache from shared preferences
  static Future<void> initializeCache() async {
    try {
      // Set current user first
      await setCurrentUser();

      final prefs = await SharedPreferences.getInstance();

      // Load cached data
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null) {
        _cachedData = json.decode(cachedJson);
      }

      // Load cached location
      final locationJson = prefs.getString(_locationKey);
      if (locationJson != null) {
        final locationData = json.decode(locationJson);
        _cachedLocation = {
          'latitude': locationData['latitude'],
          'longitude': locationData['longitude'],
        };
      }

      // Load cache timestamp
      final timestamp = prefs.getInt(_timestampKey);
      if (timestamp != null) {
        _cacheTimestamp = DateTime.fromMillisecondsSinceEpoch(timestamp);
      }

      print('Nearby cache initialized for user: ${_currentUserId ?? 'guest'}');
    } catch (e) {
      print('Error initializing nearby cache: $e');
    }
  }

  // Preload all nearby services data
  static Future<void> preloadNearbyServices(
      double latitude, double longitude) async {
    try {
      print('Starting preload of nearby services...');

      final newCacheData = <String, dynamic>{};
      final location = {'latitude': latitude, 'longitude': longitude};

      // Load data for each service type
      for (final serviceType in _serviceTypes) {
        try {
          print('Preloading $serviceType...');
          final services = await NearbyServices.searchNearbyServices(
            serviceType,
            latitude,
            longitude,
            5000, // 5km radius
          );

          newCacheData[serviceType] = services;
          print('Loaded ${services.length} $serviceType locations');
        } catch (e) {
          print('Error preloading $serviceType: $e');
          // Continue with other service types even if one fails
        }
      }

      // Update cache
      _cachedData = newCacheData;
      _cachedLocation = {'latitude': latitude, 'longitude': longitude};
      _cacheTimestamp = DateTime.now();

      // Save to shared preferences
      await _saveCacheToPrefs();

      print('Nearby services preload completed successfully');
    } catch (e) {
      print('Error during nearby services preload: $e');
    }
  }

  // Get cached services for a specific type
  static List<Map<String, dynamic>> getCachedServices(String serviceType) {
    if (!isCacheValid()) {
      return [];
    }

    final services = _cachedData[serviceType];
    if (services == null) return [];

    try {
      return List<Map<String, dynamic>>.from(services);
    } catch (e) {
      print('Error parsing cached services: $e');
      return [];
    }
  }

  // Check if cache is valid (location matches and not expired)
  static bool isCacheValid() {
    if (_cacheTimestamp == null || _cachedLocation == null) {
      return false;
    }

    // Check if cache is expired
    final now = DateTime.now();
    if (now.difference(_cacheTimestamp!) > _cacheValidity) {
      return false;
    }

    return true;
  }

  // Check if location has changed significantly (more than 1km)
  static bool hasLocationChanged(double latitude, double longitude) {
    if (_cachedLocation == null) return true;

    const double kmThreshold = 1.0; // 1km threshold
    final cachedLat = _cachedLocation!['latitude']!;
    final cachedLon = _cachedLocation!['longitude']!;

    final distance =
        _calculateDistance(cachedLat, cachedLon, latitude, longitude);
    return distance > kmThreshold;
  }

  // Get user-specific cache keys
  static String _getUserCacheKey() =>
      '${_cacheKey}_${_currentUserId ?? 'guest'}';
  static String _getUserLocationKey() =>
      '${_locationKey}_${_currentUserId ?? 'guest'}';
  static String _getUserTimestampKey() =>
      '${_timestampKey}_${_currentUserId ?? 'guest'}';

  // Save cache to shared preferences
  static Future<void> _saveCacheToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save cache data
      await prefs.setString(_getUserCacheKey(), json.encode(_cachedData));

      // Save location
      if (_cachedLocation != null) {
        await prefs.setString(
            _getUserLocationKey(), json.encode(_cachedLocation));
      }

      // Save timestamp
      if (_cacheTimestamp != null) {
        await prefs.setInt(
            _getUserTimestampKey(), _cacheTimestamp!.millisecondsSinceEpoch);
      }
    } catch (e) {
      print('Error saving cache to preferences: $e');
    }
  }

  // Clear cache (useful for logout or manual refresh)
  static Future<void> clearCache() async {
    _cachedData.clear();
    _cachedLocation = null;
    _cacheTimestamp = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_getUserCacheKey());
      await prefs.remove(_getUserLocationKey());
      await prefs.remove(_getUserTimestampKey());
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Get cache info for debugging
  static Map<String, dynamic> getCacheInfo() {
    return {
      'isValid': isCacheValid(),
      'timestamp': _cacheTimestamp?.toIso8601String(),
      'location': _cachedLocation,
      'serviceTypes': _cachedData.keys.toList(),
      'totalServices': _cachedData.values
          .where((services) => services is List)
          .map((services) => (services as List).length)
          .fold(0, (sum, count) => sum + count),
    };
  }

  // Haversine distance calculation
  static double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }
}
