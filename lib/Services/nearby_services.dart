import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

class NearbyServices {
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';

  // Map service queries to OpenStreetMap amenity types
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

    // Convert radius from meters to degrees (approximate)
    final radiusDegrees = radius / 111320; // ~111km per degree at equator

    // Overpass QL query to find amenities within radius
    final overpassQuery = '''
      [out:json][timeout:25];
      (
        node["amenity"="$osmType"](around:${radius.toDouble()},$latitude,$longitude);
        way["amenity"="$osmType"](around:${radius.toDouble()},$latitude,$longitude);
        relation["amenity"="$osmType"](around:${radius.toDouble()},$latitude,$longitude);
      );
      out center meta;
    ''';

    final url =
        Uri.parse('$_overpassUrl?data=${Uri.encodeComponent(overpassQuery)}');

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch nearby services: ${response.statusCode}');
      }

      final data = json.decode(response.body);

      if (data['elements'] == null) {
        return [];
      }

      final elements = data['elements'] as List<dynamic>;

      // Sort by distance and take top 20 results
      final sortedElements = elements
          .map((element) {
            final lat = element['lat'] ?? element['center']?['lat'];
            final lon = element['lon'] ?? element['center']?['lon'];

            if (lat == null || lon == null) return null;

            final distance = _calculateDistance(latitude, longitude, lat, lon);
            return {
              'element': element,
              'distance': distance,
            };
          })
          .where((item) => item != null)
          .toList();

      sortedElements.sort((a, b) => a!['distance'].compareTo(b!['distance']));

      return sortedElements.take(20).map((item) {
        final element = item!['element'];
        final distance = item['distance'];
        final lat = element['lat'] ?? element['center']?['lat'];
        final lon = element['lon'] ?? element['center']?['lon'];

        // Extract address information
        final tags = element['tags'] ?? {};
        final name = tags['name'] ?? 'Unnamed ${osmType.replaceAll('_', ' ')}';
        final street = tags['addr:street'] ?? '';
        final housenumber = tags['addr:housenumber'] ?? '';
        final city = tags['addr:city'] ?? '';
        final postcode = tags['addr:postcode'] ?? '';

        final addressParts = [housenumber, street, city, postcode]
            .where((part) => part.isNotEmpty)
            .toList();
        final address = addressParts.isNotEmpty
            ? addressParts.join(', ')
            : 'Address not available';

        final phone = tags['phone'] ?? tags['contact:phone'] ?? 'Not available';
        final website = tags['website'] ?? tags['contact:website'];

        // Estimate opening hours (OpenStreetMap doesn't have real-time data)
        final openingHours = tags['opening_hours'];
        final isOpen = _estimateOpenStatus(openingHours);

        return {
          'name': name,
          'address': address,
          'phone': phone,
          'distance': '${distance.toStringAsFixed(1)} km',
          'rating': 0.0, // OpenStreetMap doesn't have ratings
          'isOpen': isOpen,
          'placeId': element['id'].toString(),
          'latitude': lat,
          'longitude': lon,
          'website': website,
        };
      }).toList();
    } catch (e) {
      throw Exception('Error searching nearby services: $e');
    }
  }

  // Simple estimation of opening status based on current time
  // This is a basic implementation - real opening hours parsing would be more complex
  static bool _estimateOpenStatus(String? openingHours) {
    if (openingHours == null || openingHours.isEmpty) {
      return false; // Assume closed if no hours specified
    }

    final now = DateTime.now();
    final currentHour = now.hour;

    // Very basic parsing - assumes format like "Mo-Fr 08:00-18:00"
    // In a real implementation, you'd use a proper opening hours parser
    if (openingHours.contains('24/7')) {
      return true;
    }

    // Check if it's a weekday (Monday-Friday)
    final isWeekday = now.weekday >= 1 && now.weekday <= 5;

    if (isWeekday && openingHours.contains('Mo-Fr')) {
      // Extract hours - this is very simplified
      final hourMatch = RegExp(r'(\d{1,2}):(\d{2})-(\d{1,2}):(\d{2})')
          .firstMatch(openingHours);
      if (hourMatch != null) {
        final openHour = int.tryParse(hourMatch.group(1) ?? '0') ?? 0;
        final closeHour = int.tryParse(hourMatch.group(3) ?? '18') ?? 18;
        return currentHour >= openHour && currentHour < closeHour;
      }
    }

    // Default to closed for unknown formats
    return false;
  }

  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
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
