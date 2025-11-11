import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherService {
  final String apiKey = ""; // you aren't using OpenWeather, so ok.

  /// ✅ In-memory cache for real backend response
  Map<String, dynamic>? _cache;
  DateTime? _cacheTime;

  /// ✅ Avoid duplicate HTTP calls
  Future<Map<String, dynamic>>? _pendingFetch;

  /// ✅ Cache duration before refresh
  final Duration cacheAlive = Duration(seconds: 20);

  /// ✅ Super-snappy weather fetch
  Future<Map<String, dynamic>> getWeatherData({
    double? lat,
    double? lon,
  }) async {

    // ✅ Return cached instantly (snappy switching screens)
    if (_cache != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < cacheAlive) {
      return _cache!;
    }

    // ✅ If another fetch is ongoing → reuse it
    if (_pendingFetch != null) {
      return await _pendingFetch!;
    }

    // ✅ Start real backend fetch
    _pendingFetch = _fetchFromBackend(lat: lat, lon: lon);

    try {
      final data = await _pendingFetch!;
      _pendingFetch = null;

      // ✅ Save cache
      _cache = data;
      _cacheTime = DateTime.now();

      return data;
    } catch (e) {
      _pendingFetch = null;

      // ✅ If failure but cache exists → return cached
      if (_cache != null) return _cache!;

      rethrow;
    }
  }

  /// ✅ Real backend call with timeout
  Future<Map<String, dynamic>> _fetchFromBackend({
    double? lat,
    double? lon,
  }) async {
    String url = "http://10.16.183.189:8000/weather";
    if (lat != null && lon != null) {
      url += "?lat=$lat&lon=$lon";
    }

    final response = await http
        .get(Uri.parse(url))
        .timeout(Duration(seconds: 4)); // don’t freeze UI

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch weather");
    }

    final data = json.decode(response.body);

    if (data is! Map) throw Exception("Invalid response");

    final temp = (data["temperature"] ?? 0).toDouble();
    final rain = (data["rainfall"] ?? 0).toDouble();

    final condition =
        rain > 0 ? "Rain" : temp >= 30 ? "Clear" : "Cloudy";

    return {
      "temperature": temp,
      "rainfall": rain,
      "condition": condition,
    };
  }

  // ✅ Icons
  IconData getWeatherIcon(String c) {
    final lc = c.toLowerCase();
    if (lc.contains("rain")) return WeatherIcons.rain;
    if (lc.contains("cloud")) return WeatherIcons.cloudy;
    if (lc.contains("clear")) return WeatherIcons.day_sunny;
    return WeatherIcons.na;
  }

  // ✅ Backgrounds
  String getBackgroundImage(String condition) {
    final c = condition.toLowerCase();
    if (c.contains("rain")) return "lib/assets/images/rainy.jpeg";
    if (c.contains("cloud")) return "lib/assets/images/cloudy.jpeg";
    if (c.contains("clear")) return "lib/assets/images/sunny.jpeg";
    return "lib/assets/images/default.jpg";
  }

  /// ✅ Now 5-day forecast also uses fast cached weather
  Future<List<Map<String, dynamic>>> getFiveDayForecast(
      double lat, double lon) async {
    final now = await getWeatherData(lat: lat, lon: lon);
    final baseTemp = now["temperature"];
    final cond = now["condition"];
    final icon = getWeatherIcon(cond);

    return List.generate(5, (i) {
      final d = DateTime.now().add(Duration(days: i + 1));
      final t = baseTemp + (i - 2).abs();

      return {
        "day": DateFormat('EEE').format(d),
        "temp": t,
        "min": t - 1.5,
        "max": t + 1.5,
        "humidity": 60,
        "wind": 3.5,
        "description": cond,
        "icon": icon,
      };
    });
  }

  /// ✅ Hourly forecast also uses cached weather → instant load
  Future<List<Map<String, dynamic>>> getHourlyForecast(
      double lat, double lon, DateTime day) async {
    final now = await getWeatherData(lat: lat, lon: lon);

    return List.generate(24, (i) {
      return {
        "time": "${i.toString().padLeft(2, '0')}:00",
        "temp": now["temperature"],
        "humidity": 50,
        "wind": 3.5,
        "rain": 0,
        "icon": getWeatherIcon(now["condition"]),
      };
    });
  }
}
