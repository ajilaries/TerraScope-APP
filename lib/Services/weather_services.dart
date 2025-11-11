import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherService {
  static const String backendUrl = "http://10.0.2.2:8000/update_weather";

  /// ✅ In-memory cache for snappy UI
  Map<String, dynamic>? _cache;
  DateTime? _cacheTime;
  Future<Map<String, dynamic>>? _pendingFetch;
  final Duration cacheAlive = const Duration(seconds: 20);

  /// ✅ Fetch real weather from backend
  Future<Map<String, dynamic>> getWeatherData({
    required String token,
    required double lat,
    required double lon,
  }) async {
    // Return cache if still valid
    if (_cache != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < cacheAlive) {
      return _cache!;
    }

    // Reuse pending fetch
    if (_pendingFetch != null) {
      return await _pendingFetch!;
    }

    _pendingFetch = _fetchFromBackend(token: token, lat: lat, lon: lon);

    try {
      final data = await _pendingFetch!;
      _pendingFetch = null;
      _cache = data;
      _cacheTime = DateTime.now();
      return data;
    } catch (e) {
      _pendingFetch = null;
      if (_cache != null) return _cache!;
      rethrow;
    }
  }

  /// ✅ POST to FastAPI update_weather endpoint
  Future<Map<String, dynamic>> _fetchFromBackend({
    required String token,
    required double lat,
    required double lon,
  }) async {
    final response = await http
        .post(
          Uri.parse(backendUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"token": token, "lat": lat, "lon": lon}),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch weather: ${response.body}");
    }

    final data = json.decode(response.body);
    if (data['status'] != 'success') {
      throw Exception("Backend error: ${data['message']}");
    }

    final weather = data['weather'];
    final temp = (weather["temperature"] ?? 0).toDouble();
    final rain = (weather["rainfall"] ?? 0).toDouble();
    final humidity = (weather["humidity"] ?? 50).toDouble();
    final wind = (weather["wind_speed"] ?? 3.5).toDouble();
    final condition = rain > 0 ? "Rain" : temp >= 30 ? "Clear" : "Cloudy";

    return {
      "temperature": temp,
      "rainfall": rain,
      "humidity": humidity,
      "wind_speed": wind,
      "condition": condition,
    };
  }

  /// ✅ Weather icon helper
  IconData getWeatherIcon(String c) {
    final lc = c.toLowerCase();
    if (lc.contains("rain")) return WeatherIcons.rain;
    if (lc.contains("cloud")) return WeatherIcons.cloudy;
    if (lc.contains("clear")) return WeatherIcons.day_sunny;
    return WeatherIcons.na;
  }

  /// ✅ Background image helper
  String getBackgroundImage(String condition) {
    final c = condition.toLowerCase();
    if (c.contains("rain")) return "lib/assets/images/rainy.jpeg";
    if (c.contains("cloud")) return "lib/assets/images/cloudy.jpeg";
    if (c.contains("clear")) return "lib/assets/images/sunny.jpeg";
    return "lib/assets/images/default.jpg";
  }

  /// ✅ 5-day forecast (repeats current weather for now)
  Future<List<Map<String, dynamic>>> getFiveDayForecast({
    required String token,
    required double lat,
    required double lon,
  }) async {
    final now = await getWeatherData(token: token, lat: lat, lon: lon);
    final temp = now["temperature"];
    final cond = now["condition"];
    final icon = getWeatherIcon(cond);

    return List.generate(5, (i) {
      final d = DateTime.now().add(Duration(days: i + 1));
      return {
        "day": DateFormat('EEE').format(d),
        "temp": temp,
        "min": temp,
        "max": temp,
        "humidity": now["humidity"],
        "wind": now["wind_speed"],
        "description": cond,
        "icon": icon,
      };
    });
  }

  /// ✅ Hourly forecast (repeats current weather for now)
  Future<List<Map<String, dynamic>>> getHourlyForecast({
    required String token,
    required double lat,
    required double lon,
    required DateTime day,
  }) async {
    final now = await getWeatherData(token: token, lat: lat, lon: lon);
    final temp = now["temperature"];
    final cond = now["condition"];
    final icon = getWeatherIcon(cond);

    return List.generate(24, (i) {
      return {
        "time": "${i.toString().padLeft(2, '0')}:00",
        "temp": temp,
        "humidity": now["humidity"],
        "wind": now["wind_speed"],
        "rain": now["rainfall"],
        "icon": icon,
      };
    });
  }
}
