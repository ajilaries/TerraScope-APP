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
    final locService = LocationService();
    return await locService.getCurrentPositionFast();
  }

  /// Reverse geocode to a human readable place name
  static Future<String> reverseGeocode(double lat, double lon) async {
    try {
      final locService = LocationService();
      final admin = await locService.getAdministrativeDetails(lat, lon);
      final parts = [admin['city'], admin['district'], admin['state']]
          .where((s) => s?.isNotEmpty ?? false)
          .toList();
      if (parts.isNotEmpty) return parts.join(', ');
    } catch (_) {}
    return "Current Location";
  }

  /// Fetch weather using OpenWeatherMap if API key found in .env -> OPENWEATHER_API_KEY
  /// returns map with keys: temp (double) and optionally aqi (int)
  static Future<Map<String, dynamic>> fetchWeather(
      double lat, double lon) async {
    final result = <String, dynamic>{};
    try {
      final token = await DeviceService.getDeviceToken();
      final weatherSvc = WeatherService();
      final data =
          await weatherSvc.getWeatherData(token: token, lat: lat, lon: lon);
      if (data.containsKey('temperature')) {
        result['temp'] = (data['temperature'] as num?)?.toDouble();
      }

      // Try AQI via WeatherService first, fallback to AQIService
      final aqiData = await weatherSvc.getAQIData(lat: lat, lon: lon);
      if (aqiData.containsKey('aqi')) {
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
}
