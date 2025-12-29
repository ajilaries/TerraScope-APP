import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'weather_services.dart';
import 'location_service.dart';

class CommuteService {
  static const String _openRouteUrl =
      'https://api.openrouteservice.org/v2/directions/driving-car';
  static const String _tomTomUrl =
      'https://api.tomtom.com/traffic/services/4/flowSegmentData/relative0/10/json';

  static Future<Map<String, dynamic>?> getRoute(
      double startLat, double startLon, double endLat, double endLon) async {
    try {
      final apiKey = dotenv.env['OPENROUTESERVICE_API_KEY'];
      if (apiKey == null) return null;

      final url = Uri.parse(
          '$_openRouteUrl?api_key=$apiKey&start=$startLon,$startLat&end=$endLon,$endLat');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List?;
        if (features != null && features.isNotEmpty) {
          final properties = features[0]['properties'];
          return {
            'duration': properties['segments'][0]['duration'] as int,
            'distance': properties['segments'][0]['distance'] as double,
          };
        }
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getTrafficData(
      double lat, double lon) async {
    try {
      final apiKey = dotenv.env['TOMTOM_API_KEY'];
      if (apiKey == null) return null;

      final url =
          Uri.parse('$_tomTomUrl?point=$lat,$lon&unit=KMPH&key=$apiKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final flowSegmentData = data['flowSegmentData'];
        return {
          'currentSpeed': flowSegmentData['currentSpeed'],
          'freeFlowSpeed': flowSegmentData['freeFlowSpeed'],
          'confidence': flowSegmentData['confidence'],
          'roadClosure': flowSegmentData['roadClosure'],
        };
      }
    } catch (e) {
      print('Error fetching traffic data: $e');
    }
    return null;
  }

  static Future<int> calculateSafetyScore(double lat, double lon) async {
    int score = 100; // Base score

    // Weather impact
    final weather = await WeatherService.getWeatherData(lat, lon);
    if (weather != null) {
      final rain = weather['rain']?['1h'] ?? 0.0;
      final wind = weather['wind']['speed'] as num;
      if (rain > 5) score -= 20;
      if (wind > 10) score -= 15;
    }

    // AQI impact
    final aqiData = await WeatherService.getAQIData(lat, lon);
    if (aqiData != null) {
      final aqi = aqiData['aqi'] as int;
      if (aqi > 100)
        score -= 25;
      else if (aqi > 50) score -= 10;
    }

    // Traffic impact
    final traffic = await getTrafficData(lat, lon);
    if (traffic != null) {
      final currentSpeed = traffic['currentSpeed'] as num;
      final freeFlowSpeed = traffic['freeFlowSpeed'] as num;
      if (currentSpeed < freeFlowSpeed * 0.5)
        score -= 30;
      else if (currentSpeed < freeFlowSpeed * 0.8) score -= 15;
    }

    return score.clamp(0, 100);
  }

  static Future<List<Map<String, dynamic>>> getRealAlerts(
      double lat, double lon) async {
    List<Map<String, dynamic>> alerts = [];

    // Weather alerts
    final weather = await WeatherService.getWeatherData(lat, lon);
    if (weather != null) {
      final rain = weather['rain']?['1h'] ?? 0.0;
      if (rain > 2) {
        alerts.add({
          'title': 'Heavy Rain Alert',
          'description': 'Heavy rainfall expected. Drive carefully.',
          'time': 'Now',
          'type': 'weather',
        });
      }
    }

    // Traffic alerts
    final traffic = await getTrafficData(lat, lon);
    if (traffic != null) {
      final currentSpeed = traffic['currentSpeed'] as num;
      final freeFlowSpeed = traffic['freeFlowSpeed'] as num;
      if (currentSpeed < freeFlowSpeed * 0.5) {
        alerts.add({
          'title': 'Heavy Traffic',
          'description': 'Significant traffic congestion ahead.',
          'time': 'Now',
          'type': 'traffic',
        });
      }
    }

    // AQI alerts
    final aqiData = await WeatherService.getAQIData(lat, lon);
    if (aqiData != null) {
      final aqi = aqiData['aqi'] as int;
      if (aqi > 150) {
        alerts.add({
          'title': 'Poor Air Quality',
          'description': 'High pollution levels. Consider wearing a mask.',
          'time': 'Now',
          'type': 'safety',
        });
      }
    }

    return alerts;
  }

  static Future<Map<String, dynamic>> getMetroTimings(
      double lat, double lon) async {
    // TODO: Integrate with KMRL API for real metro timings
    // Kochi Metro service areas (simplified for demo)
    // In real implementation, integrate with Kochi Metro API
    final metroStations = {
      'Aluva': {'lat': 10.1076, 'lon': 76.3570},
      'Palarivattom': {'lat': 10.0159, 'lon': 76.3086},
      'Vyttila': {'lat': 9.9667, 'lon': 76.3222},
      'Fort Kochi': {'lat': 9.9658, 'lon': 76.2425},
    };

    // Find nearest metro station
    String nearestStation = 'Unknown';
    double minDistance = double.infinity;

    metroStations.forEach((station, coords) {
      final distance =
          _calculateDistance(lat, lon, coords['lat']!, coords['lon']!);
      if (distance < minDistance) {
        minDistance = distance;
        nearestStation = station;
      }
    });

    if (minDistance < 5.0) {
      // Within 5km of metro station
      // Simulate real-time metro timings based on current time
      final now = DateTime.now();
      final minutes = now.minute;
      final nextTrain1 = (15 - (minutes % 15)) % 15; // Every 15 mins
      final nextTrain2 = nextTrain1 + 15;

      return {
        'nearestStation': nearestStation,
        'nextTrain1': '$nextTrain1 mins',
        'nextTrain2': '$nextTrain2 mins',
        'frequency': 'Every 10-15 mins',
        'platform': 'Platform ${nextTrain1 % 2 + 1}',
      };
    } else {
      return {
        'status': 'No metro service within 5km',
        'nearestStation': nearestStation,
        'distance': '${minDistance.toStringAsFixed(1)} km away',
      };
    }
  }

  static Future<Map<String, dynamic>> getBusStatus(
      double lat, double lon) async {
    // TODO: Integrate with KSRTC API for Kerala and other state RTC APIs
    // For now, using simulated data - replace with real API calls
    final place = await LocationService.getAddressFromCoordinates(lat, lon);
    final now = DateTime.now();

    // Different bus routes for different areas
    if (place != null && place.contains('Kochi')) {
      // Simulate realistic bus timings based on current time
      final minute = now.minute;
      final busDelay1 = (minute % 10) + 1; // 1-10 mins delay
      final busDelay2 = (minute % 8) + 2; // 2-9 mins delay
      final busDelay3 = (minute % 12) + 3; // 3-14 mins delay

      return {
        'bus15C': 'Arriving in $busDelay1 mins',
        'bus12A': 'Delayed by $busDelay2 mins',
        'bus8B': 'On time, $busDelay3 mins away',
        'location': place.split(',')[0], // Show area name
      };
    } else if (place != null) {
      // For other cities, show generic bus info
      return {
        'status': 'Bus service available',
        'location': place.split(',')[0],
        'nextBus': '5-10 mins',
      };
    } else {
      return {
        'status': 'No bus data available for this location',
      };
    }
  }

  static Future<Map<String, dynamic>> getCabFareEstimate(
      double lat, double lon, double destLat, double destLon) async {
    // Calculate fare based on distance
    final route = await getRoute(lat, lon, destLat, destLon);
    if (route != null) {
      final distanceKm = route['distance'] / 1000; // Convert to km
      final autoFare = (distanceKm * 15) + 20; // Base fare + per km
      final miniFare = (distanceKm * 12) + 30;
      final sedanFare = (distanceKm * 18) + 50;
      return {
        'autoRickshaw':
            '₹${autoFare.toStringAsFixed(0)}-₹${(autoFare + 20).toStringAsFixed(0)}',
        'uberOlaMini':
            '₹${miniFare.toStringAsFixed(0)}-₹${(miniFare + 30).toStringAsFixed(0)}',
        'uberOlaSedan':
            '₹${sedanFare.toStringAsFixed(0)}-₹${(sedanFare + 50).toStringAsFixed(0)}',
      };
    } else {
      return {
        'autoRickshaw': '₹50-70',
        'uberOlaMini': '₹80-120',
        'uberOlaSedan': '₹150-200',
      };
    }
  }

  static Future<Map<String, dynamic>> getTrafficDensity(
      double lat, double lon) async {
    final traffic = await getTrafficData(lat, lon);
    if (traffic != null) {
      final currentSpeed = traffic['currentSpeed'] as num;
      final freeFlowSpeed = traffic['freeFlowSpeed'] as num;
      final ratio = currentSpeed / freeFlowSpeed;
      String density;
      if (ratio > 0.8) {
        density = 'Light traffic';
      } else if (ratio > 0.5) {
        density = 'Moderate traffic';
      } else {
        density = 'Heavy traffic';
      }
      return {
        'density': density,
        'currentSpeed': '${currentSpeed.toStringAsFixed(0)} km/h',
        'freeFlowSpeed': '${freeFlowSpeed.toStringAsFixed(0)} km/h',
      };
    } else {
      return {
        'density': 'Traffic data unavailable',
      };
    }
  }

  static double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    final double dLat = (lat2 - lat1) * pi / 180;
    final double dLon = (lon2 - lon1) * pi / 180;
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }
}
