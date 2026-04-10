import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:terra_scope_apk/Services/location_service.dart';
import 'package:terra_scope_apk/Services/weather_services.dart';
import 'package:terra_scope_apk/Services/aqi_service.dart';
import 'package:terra_scope_apk/Services/device_service.dart';

class CommuteService {
  /// Get current device position (requests permission if needed)
  static Future<Position> getCurrentPosition() async {
    // Delegate to LocationService which handles permission and fast fetch
    final position = await LocationService.getCurrentPositionFast();
    if (position == null) {
      throw Exception('Unable to get current position');
    }
    return position;
  }

  /// Reverse geocode to a human readable place name
  static Future<String> reverseGeocode(double lat, double lon) async {
    try {
      final admin = await LocationService.getAdministrativeDetails(lat, lon);
      if (admin != null) {
        final parts = [admin['city'], admin['district'], admin['state']]
            .where((s) => s != null && s!.isNotEmpty)
            .toList();
        if (parts.isNotEmpty) return parts.join(', ');
      }
    } catch (_) {}
    return "Current Location";
  }

  /// Fetch weather using the shared WeatherService / AQIService
  /// returns map with keys: temp (double) and optionally aqi (int)
  static Future<Map<String, dynamic>> fetchWeather(
      double lat, double lon) async {
    final result = <String, dynamic>{};
    try {
      final data = await WeatherService.getCurrentWeather(lat, lon);
      if (data != null && data.containsKey('main')) {
        final main = data['main'];
        if (main != null && main.containsKey('temp')) {
          result['temp'] = (main['temp'] as num?)?.toDouble();
        }
      }

      // Try AQI via WeatherService first, fallback to AQIService
      final aqiData = await WeatherService.getAQIData(lat, lon);
      if (aqiData != null && aqiData.containsKey('aqi')) {
        final a = aqiData['aqi'];
        if (a is int) result['aqi'] = a;
      } else {
        final aqiSvc = AQIService();
        final got = await aqiSvc.getAQI(lat, lon);
        if (got != null) result['aqi'] = got;
      }
    } catch (e) {
      // keep result empty so callers can fallback to mock
      print('CommuteService.fetchWeather fallback: $e');
    }

    return result;
  }

  /// Plan route by geocoding addresses and optionally using Google Directions
  /// If GOOGLE_MAPS_API_KEY not present, returns mock ETA/distance
  static Future<Map<String, String>> planRoute(
      String origin, String destination) async {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

    try {
      // Try geocoding both addresses to coordinates
      final origPl = await locationFromAddress(origin);
      final destPl = await locationFromAddress(destination);

      final olat = origPl.first.latitude;
      final olon = origPl.first.longitude;
      final dlat = destPl.first.latitude;
      final dlon = destPl.first.longitude;

      if (apiKey != null && apiKey.isNotEmpty) {
        final url = Uri.parse(
            'https://maps.googleapis.com/maps/api/directions/json?origin=\$olat,\$olon&destination=\$dlat,\$dlon&key=\$apiKey');
        final resp = await http.get(url).timeout(const Duration(seconds: 8));
        if (resp.statusCode == 200) {
          final data = json.decode(resp.body);
          final route = data['routes'] != null && data['routes'].isNotEmpty
              ? data['routes'][0]
              : null;
          final leg =
              route != null && route['legs'] != null && route['legs'].isNotEmpty
                  ? route['legs'][0]
                  : null;
          if (leg != null) {
            final duration = leg['duration']?['text'];
            final distance = leg['distance']?['text'];
            return {
              'eta': duration ?? '',
              'distance': distance ?? '',
            };
          }
        }
      }

      // Fallback to simple estimate if no API key or directions fail
      final approxMinutes =
          (((((olat - dlat).abs() + (olon - dlon).abs()) * 111) / 40) * 60)
              .toInt();
      final approxKm =
          (((olat - dlat).abs() + (olon - dlon).abs()) * 111).abs();
      return {
        'eta': '${(approxMinutes.clamp(8, 90))} mins',
        'distance': '${approxKm.toStringAsFixed(1)} km',
      };
    } catch (_) {
      // Geocoding failed — return mock
      return {
        'eta': '25 mins',
        'distance': '9.2 km',
      };
    }
  }

  /// Get nearest metro station (mock implementation)
  static Future<Map<String, dynamic>> getNearestMetro(
      double lat, double lon) async {
    // Mock data - in real implementation, this would call a transit API
    return {
      'name': 'Central Station',
      'distance': '0.5 km',
      'walkingTime': '6 mins',
      'lines': ['Red Line', 'Blue Line'],
    };
  }

  /// Get nearest bus stop (mock implementation)
  static Future<Map<String, dynamic>> getNearestBusStop(
      double lat, double lon) async {
    // Mock data - in real implementation, this would call a transit API
    return {
      'name': 'Main Street Stop',
      'distance': '0.2 km',
      'walkingTime': '3 mins',
      'routes': ['Route 15', 'Route 22'],
    };
  }

  /// Calculate safety score for a route (mock implementation)
  static Future<int> calculateSafetyScore(
      double startLat, double startLon, double endLat, double endLon) async {
    // Mock safety score calculation based on distance and random factors
    final distance = ((startLat - endLat).abs() + (startLon - endLon).abs()) *
        111; // Rough km
    final baseScore = 85; // Base safety score
    final distancePenalty =
        (distance * 2).clamp(0, 15); // Penalty for longer distances
    return (baseScore - distancePenalty).round().clamp(0, 100);
  }

  /// Get real-time alerts for commute (mock implementation)
  static Future<List<Map<String, dynamic>>> getRealAlerts(
      double lat, double lon) async {
    // Mock alerts - in real implementation, this would fetch from traffic/weather APIs
    return [
      {
        'type': 'traffic',
        'title': 'Heavy Traffic Ahead',
        'description': 'Expect delays due to construction on Main Street',
        'severity': 'moderate',
      },
      {
        'type': 'weather',
        'title': 'Light Rain Expected',
        'description': 'Light rain in the next 30 minutes',
        'severity': 'low',
      },
    ];
  }

  /// Get metro timings (mock implementation)
  static Future<List<Map<String, dynamic>>> getMetroTimings(
      String stationName) async {
    // Mock metro timings
    return [
      {'line': 'Red Line', 'direction': 'Northbound', 'time': '2 mins'},
      {'line': 'Red Line', 'direction': 'Southbound', 'time': '5 mins'},
      {'line': 'Blue Line', 'direction': 'Eastbound', 'time': '8 mins'},
    ];
  }

  /// Get bus status (mock implementation)
  static Future<Map<String, dynamic>> getBusStatus(String route) async {
    // Mock bus status
    return {
      'route': route,
      'status': 'On Time',
      'nextArrival': '12 mins',
      'crowdLevel': 'Moderate',
    };
  }

  /// Get cab fare estimate (mock implementation)
  static Future<Map<String, dynamic>> getCabFareEstimate(
      double startLat, double startLon, double endLat, double endLon) async {
    final distance = ((startLat - endLat).abs() + (startLon - endLon).abs()) *
        111; // Rough km
    final baseFare = 50.0;
    final perKmRate = 12.0;
    final estimatedFare = baseFare + (distance * perKmRate);

    return {
      'estimatedFare': estimatedFare.round(),
      'currency': 'INR',
      'distance': distance.toStringAsFixed(1) + ' km',
      'surgeMultiplier': 1.0,
    };
  }

  /// Get traffic density (mock implementation)
  static Future<String> getTrafficDensity(double lat, double lon) async {
    // Mock traffic density based on time of day
    final hour = DateTime.now().hour;
    if (hour >= 8 && hour <= 10 || hour >= 17 && hour <= 19) {
      return 'Heavy';
    } else if (hour >= 11 && hour <= 16) {
      return 'Light';
    } else {
      return 'Moderate';
    }
  }
}
