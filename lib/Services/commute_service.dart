import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'weather_services.dart';

class CommuteService {
  // ===================== GENERAL ROUTE =====================
  static Future<Map<String, dynamic>?> getRoute(
      double srcLat, double srcLon, double destLat, double destLon) async {
    final route = await getRouteWithTraffic(srcLat, srcLon, destLat, destLon);
    if (route != null) {
      final durationSec =
          int.tryParse(route['duration'].replaceAll('s', '')) ?? 0;
      return {
        'duration': durationSec,
        'distance': route['distanceKm'] * 1000,
      };
    }
    return null;
  }

  // ===================== GOOGLE ROUTES (TRAFFIC AWARE) =====================
  static Future<Map<String, dynamic>?> getRouteWithTraffic(
      double srcLat, double srcLon, double destLat, double destLon) async {
    final key = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (key == null) return null;

    final url =
        Uri.parse('https://routes.googleapis.com/directions/v2:computeRoutes');

    final body = {
      "origin": {
        "location": {
          "latLng": {"latitude": srcLat, "longitude": srcLon}
        }
      },
      "destination": {
        "location": {
          "latLng": {"latitude": destLat, "longitude": destLon}
        }
      },
      "travelMode": "DRIVE",
      "routingPreference": "TRAFFIC_AWARE"
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": key,
        "X-Goog-FieldMask": "routes.duration,routes.distanceMeters"
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'] == null || data['routes'].isEmpty) return null;

      final route = data['routes'][0];
      return {
        "duration": route['duration'], // e.g. "2100s"
        "distanceKm": (route['distanceMeters'] / 1000).toDouble(),
      };
    }
    return null;
  }

  // ===================== TRANSIT (BUS / METRO) =====================
  static Future<Map<String, dynamic>?> getTransitRoute(double srcLat,
      double srcLon, double destLat, double destLon, String mode) async {
    final key = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (key == null) return null;

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=$srcLat,$srcLon'
      '&destination=$destLat,$destLon'
      '&mode=transit'
      '&transit_mode=$mode'
      '&key=$key',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) return null;

    final data = json.decode(response.body);
    if (data['routes'] == null || data['routes'].isEmpty) return null;

    final leg = data['routes'][0]['legs'][0];

    return {
      "duration": leg['duration']['text'],
      "arrival": leg['arrival_time']?['text'] ?? "Soon",
      "departure": leg['departure_time']?['text'] ?? "Now",
      "distance": leg['distance']['text'],
      "source": "google-transit",
    };
  }

  // ===================== CAB ESTIMATION =====================
  static Future<Map<String, dynamic>> getCabEstimate(
      double srcLat, double srcLon, double destLat, double destLon) async {
    final route = await getRouteWithTraffic(srcLat, srcLon, destLat, destLon);
    if (route == null) return {"eta": "N/A", "mini": "₹--", "sedan": "₹--"};

    final distanceKm = route['distanceKm'] as double;
    double surge = 1.0;
    if (distanceKm < 5) surge = 1.2;
    if (isPeakHour()) surge = 1.4;

    return {
      "eta": route['duration'],
      "mini": "₹${(distanceKm * 12 * surge + 30).toInt()}",
      "sedan": "₹${(distanceKm * 18 * surge + 50).toInt()}",
    };
  }

  // ===================== SAFETY SCORE =====================
  static Future<int> calculateSafetyScore(double lat, double lon) async {
    int score = 100;
    final weather = await WeatherService.getWeatherData(lat, lon);
    if (weather != null) {
      final rain = weather['rain']?['1h'] ?? 0.0;
      final wind = weather['wind']['speed'] ?? 0.0;
      if (rain > 5) score -= 20;
      if (wind > 10) score -= 15;
    }

    final aqiData = await WeatherService.getAQIData(lat, lon);
    if (aqiData != null) {
      final aqi = aqiData['aqi'] ?? 0;
      if (aqi > 100) {
        score -= 25;
      } else if (aqi > 50) {
        score -= 10;
      }
    }

    return score.clamp(0, 100);
  }

  // ===================== ALERTS =====================
  static Future<List<Map<String, dynamic>>> getRealAlerts(
      double lat, double lon) async {
    List<Map<String, dynamic>> alerts = [];

    final weather = await WeatherService.getWeatherData(lat, lon);
    if (weather != null && (weather['rain']?['1h'] ?? 0) > 2) {
      alerts.add({
        'title': 'Heavy Rain',
        'description': 'Rainfall may cause delays',
        'type': 'weather'
      });
    }

    final aqi = await WeatherService.getAQIData(lat, lon);
    if (aqi != null && (aqi['aqi'] ?? 0) > 150) {
      alerts.add({
        'title': 'Poor Air Quality',
        'description': 'Avoid outdoor travel if possible',
        'type': 'safety'
      });
    }

    return alerts;
  }

  // ===================== BUS & METRO =====================
  static Future<Map<String, dynamic>> getMetroTimings(
      double srcLat, double srcLon, double destLat, double destLon) async {
    // Get nearest metro station from current location
    final nearestMetro = await getNearestMetro(srcLat, srcLon);
    if (nearestMetro == null) return {'status': 'No metro service available'};

    // Get route from current location to nearest metro station
    final route = await getTransitRoute(
        srcLat, srcLon, nearestMetro['lat'], nearestMetro['lon'], 'subway');
    if (route != null) {
      return {
        'station': nearestMetro['name'],
        'departure': route['departure'] ?? 'N/A',
        'arrival': route['arrival'] ?? 'N/A',
        'duration': route['duration'] ?? 'N/A',
      };
    }
    return {'status': 'No metro service available'};
  }

  static Future<Map<String, dynamic>> getBusStatus(
      double srcLat, double srcLon, double destLat, double destLon) async {
    // Get nearest bus stop from current location
    final nearestBus = await getNearestBusStop(srcLat, srcLon);
    if (nearestBus == null) return {'status': 'No bus service available'};

    // Get route from current location to nearest bus stop
    final route = await getTransitRoute(srcLat, srcLon,
        nearestBus['lat'] as double, nearestBus['lon'] as double, 'bus');
    if (route != null) {
      return {
        'stop': nearestBus['name'],
        'departure': route['departure'] ?? 'N/A',
        'arrival': route['arrival'] ?? 'N/A',
        'duration': route['duration'] ?? 'N/A',
      };
    }
    return {'status': 'No bus service available'};
  }

  // ===================== CAB FARE ESTIMATE =====================
  static Future<Map<String, dynamic>> getCabFareEstimate(
      double srcLat, double srcLon, double destLat, double destLon) async {
    final estimate = await getCabEstimate(srcLat, srcLon, destLat, destLon);
    return {
      'autoRickshaw': estimate['mini'] ?? '₹--',
      'uberOlaMini': estimate['mini'] ?? '₹--',
      'uberOlaSedan': estimate['sedan'] ?? '₹--',
    };
  }

  // ===================== TRAFFIC DENSITY =====================
  static Future<Map<String, dynamic>> getTrafficDensity(
      double srcLat, double srcLon, double destLat, double destLon) async {
    final route = await getRouteWithTraffic(srcLat, srcLon, destLat, destLon);
    if (route != null) {
      final durationSec =
          int.tryParse(route['duration'].replaceAll('s', '')) ?? 0;
      final distanceKm = route['distanceKm'] as double;
      final avgSpeed = distanceKm / (durationSec / 3600);
      String density;
      if (avgSpeed > 40) {
        density = 'Light';
      } else if (avgSpeed > 20)
        density = 'Moderate';
      else
        density = 'Heavy';
      return {
        'density': density,
        'currentSpeed': '${avgSpeed.toStringAsFixed(1)} km/h',
        'freeFlowSpeed': '50 km/h',
      };
    }
    return {
      'density': 'Unknown',
      'currentSpeed': 'N/A',
      'freeFlowSpeed': 'N/A'
    };
  }

  // ===================== UTILITIES =====================
  static bool isPeakHour() {
    final hour = DateTime.now().hour;
    return (hour >= 8 && hour <= 10) || (hour >= 17 && hour <= 20);
  }

  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  // Get nearest metro station
  static Future<Map<String, dynamic>?> getNearestMetro(
      double lat, double lon) async {
    final key = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (key == null) return null;

    // First try with metro keyword
    var url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=$lat,$lon&radius=2000&type=transit_station&keyword=metro&key=$key',
    );

    var res = await http.get(url);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        final stop = data['results'][0];
        return {
          'name': stop['name'],
          'lat': stop['geometry']['location']['lat'],
          'lon': stop['geometry']['location']['lng'],
        };
      }
    }

    // Fallback: search for any transit station without keyword
    url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=$lat,$lon&radius=2000&type=transit_station&key=$key',
    );

    res = await http.get(url);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        // Filter results to find metro-like stations
        final results = data['results'] as List;
        for (final result in results) {
          final name = result['name'].toString().toLowerCase();
          if (name.contains('metro') ||
              name.contains('subway') ||
              name.contains('underground')) {
            return {
              'name': result['name'],
              'lat': result['geometry']['location']['lat'],
              'lon': result['geometry']['location']['lng'],
            };
          }
        }
        // If no metro found, return the first transit station
        final stop = data['results'][0];
        return {
          'name': stop['name'],
          'lat': stop['geometry']['location']['lat'],
          'lon': stop['geometry']['location']['lng'],
        };
      }
    }
    return null;
  }

  // Get nearest bus stop
  static Future<Map<String, dynamic>?> getNearestBusStop(
      double lat, double lon) async {
    final key = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (key == null) return null;

    // First try with bus keyword
    var url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=$lat,$lon&radius=2000&type=transit_station&keyword=bus&key=$key',
    );

    var res = await http.get(url);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        final stop = data['results'][0];
        return {
          'name': stop['name'],
          'lat': stop['geometry']['location']['lat'],
          'lon': stop['geometry']['location']['lng'],
        };
      }
    }

    // Fallback: search for any transit station without keyword
    url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=$lat,$lon&radius=2000&type=transit_station&key=$key',
    );

    res = await http.get(url);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        // Filter results to find bus-like stations
        final results = data['results'] as List;
        for (final result in results) {
          final name = result['name'].toString().toLowerCase();
          if (name.contains('bus') ||
              name.contains('stop') ||
              name.contains('station')) {
            return {
              'name': result['name'],
              'lat': result['geometry']['location']['lat'],
              'lon': result['geometry']['location']['lng'],
            };
          }
        }
        // If no bus stop found, return the first transit station
        final stop = data['results'][0];
        return {
          'name': stop['name'],
          'lat': stop['geometry']['location']['lat'],
          'lon': stop['geometry']['location']['lng'],
        };
      }
    }
    return null;
  }
}
