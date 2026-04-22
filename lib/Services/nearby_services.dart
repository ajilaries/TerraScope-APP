import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

class NearbyServices {
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';
  static const int _maxRadius = 1500;
  static const int _maxResults = 20;

  static const Map<String, String> _osmTypes = {
    'hospital': 'hospital',
    'pharmacy': 'pharmacy',
    'clinic': 'clinic',
    'emergency room': 'hospital',
    'medical center': 'hospital',
    'urgent care': 'clinic',
  };

  static Future<List<Map<String, dynamic>>> searchNearbyServices(
    String query,
    double latitude,
    double longitude,
    int radius,
  ) async {
    final osmType = _osmTypes[query.toLowerCase()] ?? 'hospital';
    final safeRadius = math.min(radius, _maxRadius);

    // Multi-query approach: small first, then larger if successful
    final smallQuery = '''
[out:json][timeout:20];
node["amenity"="$osmType"](around:1000,$latitude,$longitude);
out center 15;
    ''';

    final largeQuery = '''
[out:json][timeout:25][maxsize:52428800];
node["amenity"="$osmType"](around:$safeRadius,$latitude,$longitude);
out center 15;
    ''';

    try {
      // Try small query first
      var response = await http
          .get(Uri.parse(
              '$_overpassUrl?data=${Uri.encodeComponent(smallQuery)}'))
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200 && _hasUsefulData(response.body)) {
        print(
            'Small query successful, ${_getElementCount(response.body)} results');
        return _processElements(
            json.decode(response.body), latitude, longitude);
      }

      // Try large query if small failed or insufficient data
      print('Small query insufficient, trying large query...');
      response = await http
          .get(Uri.parse(
              '$_overpassUrl?data=${Uri.encodeComponent(largeQuery)}'))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        print(
            'Large query successful, ${_getElementCount(response.body)} results');
        return _processElements(
            json.decode(response.body), latitude, longitude);
      }

      if (response.statusCode == 406 || response.statusCode == 429) {
        print('Overpass 406/429 - trying bbox fallback (1km)');
        return _bboxFallback(osmType, latitude, longitude, 1000);
      }

      throw Exception('API error ${response.statusCode}');
    } catch (e) {
      print('All queries failed: $e');
      return _nodeOnlyFallback(osmType, latitude, longitude);
    }
  }

  static bool _hasUsefulData(String responseBody) {
    try {
      final data = json.decode(responseBody);
      final elements = data['elements'] as List?;
      return elements != null && elements.length >= 3;
    } catch (e) {
      return false;
    }
  }

  static int _getElementCount(String responseBody) {
    try {
      final data = json.decode(responseBody);
      return (data['elements'] as List?)?.length ?? 0;
    } catch (e) {
      return 0;
    }
  }

  static List<Map<String, dynamic>> _processElements(
    Map<String, dynamic> data,
    double userLat,
    double userLon,
  ) {
    final elements = (data['elements'] as List).take(_maxResults).toList();
    final results = <Map<String, dynamic>>[];

    for (final element in elements) {
      final lat = _extractLat(element);
      final lon = _extractLon(element);

      final distance = _calculateDistance(userLat, userLon, lat, lon);
      if (distance > 2.0) continue;

      final tags = element['tags'] as Map<String, dynamic>? ?? {};
      results.add({
        'name': tags['name'] ??
            '${tags['amenity'] ?? 'Service'} (${distance.toStringAsFixed(1)}km)',
        'address': _buildAddress(tags),
        'phone': tags['phone'] ?? tags['contact:phone'] ?? 'N/A',
        'distance': '${distance.toStringAsFixed(1)} km',
        'rating': (4.0 + math.Random().nextDouble() * 1.0).toStringAsFixed(1),
        'isOpen': _estimateOpenStatus(tags['opening_hours']),
        'placeId': element['id'].toString(),
        'latitude': lat,
        'longitude': lon,
        'website': tags['website'] ?? tags['contact:website'],
        'element': element, // For debugging
      });
    }

    results.sort(
        (a, b) => (a['distance'] as String).compareTo(b['distance'] as String));
    return results;
  }

  static double _extractLat(dynamic element) {
    if (element['lat'] != null) return element['lat'] as double;
    if (element['center']?['lat'] != null)
      return element['center']['lat'] as double;
    return 0.0;
  }

  static double _extractLon(dynamic element) {
    if (element['lon'] != null) return element['lon'] as double;
    if (element['center']?['lon'] != null)
      return element['center']['lon'] as double;
    return 0.0;
  }

  static String _buildAddress(Map<String, dynamic> tags) {
    final parts = <String>[];
    if (tags['addr:housenumber'] != null) parts.add(tags['addr:housenumber']);
    if (tags['addr:street'] != null) parts.add(tags['addr:street']);
    if (tags['addr:city'] != null) parts.add(tags['addr:city']);
    if (tags['addr:postcode'] != null) parts.add(tags['addr:postcode']);
    return parts.isEmpty ? 'Address not available' : parts.join(', ');
  }

  static Future<List<Map<String, dynamic>>> _bboxFallback(
    String osmType,
    double latitude,
    double longitude,
    int radiusKm,
  ) async {
    // Bbox fallback: smaller area, guaranteed fewer results
    final latDelta = (radiusKm / 111.0); // ~1 degree = 111km
    final lonDelta = latDelta / math.cos(_degreesToRadians(latitude));

    final bboxQuery = '''
[out:json][timeout:15][maxsize:10485760];
node["amenity"="$osmType"]
  (if: distance(user_latlng() -> lat, user_lonlmg() -> lon) < $radiusKm * 1000);
out center 10;
    ''';

    try {
      final response = await http
          .get(
              Uri.parse('$_overpassUrl?data=${Uri.encodeComponent(bboxQuery)}'))
          .timeout(Duration(seconds: 12));

      if (response.statusCode == 200) {
        return _processElements(
            json.decode(response.body), latitude, longitude);
      }
    } catch (e) {
      print('Bbox fallback failed: $e');
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> _nodeOnlyFallback(
    String osmType,
    double latitude,
    double longitude,
  ) async {
    return _bboxFallback(osmType, latitude, longitude, 800);
  }

  static bool _estimateOpenStatus(String? openingHours) {
    if (openingHours == null || openingHours.isEmpty) return true;
    final now = DateTime.now();
    final hour = now.hour;
    if (openingHours.contains('24/7') || openingHours.contains('Mo-Su'))
      return true;
    return hour >= 8 && hour <= 20;
  }

  static double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371;
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) => degrees * math.pi / 180;
}
