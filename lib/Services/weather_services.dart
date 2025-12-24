import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  static const String backendUrl = "http://10.0.2.2:8000/update_weather";

  /// ✅ In-memory cache for snappy UI
  Map<String, dynamic>? _cache;
  DateTime? _cacheTime;
  Future<Map<String, dynamic>>? _pendingFetch;
  final Duration cacheAlive = const Duration(seconds: 20);

  /// ✅ Fetch real weather from OpenWeatherMap API
  Future<Map<String, dynamic>> getWeatherData({
    required String token,
    required double lat,
    required double lon,
  }) async {
    if (_cache != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < cacheAlive) {
      return _cache!;
    }

    if (_pendingFetch != null) return await _pendingFetch!;

    _pendingFetch = _fetchFromOpenWeather(lat: lat, lon: lon);

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

  Future<Map<String, dynamic>> _fetchFromOpenWeather({
    required double lat,
    required double lon,
  }) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception("OpenWeather API key not found in .env");
    }

    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric",
    );

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch weather: ${response.body}");
    }

    final data = json.decode(response.body);
    final main = data['main'];
    final weather = data['weather'][0];
    final wind = data['wind'];

    final temp = (main['temp'] ?? 0).toDouble();
    final humidity = (main['humidity'] ?? 50).toDouble();
    final windSpeed =
        (wind['speed'] ?? 0).toDouble() * 3.6; // Convert m/s to km/h
    final condition = weather['main'] ?? 'Unknown';
    final rain = (data['rain']?['1h'] ?? 0).toDouble();

    return {
      "temperature": temp,
      "rainfall": rain,
      "humidity": humidity,
      "wind_speed": windSpeed,
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

  /// ✅ 7-day forecast from OpenWeather
  Future<List<Map<String, dynamic>>> getSevenDayForecast({
    required double lat,
    required double lon,
  }) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception("OpenWeather API key not found in .env");
    }

    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&exclude=current,minutely,hourly,alerts&appid=$apiKey&units=metric",
    );

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch forecast: ${response.body}");
    }

    final data = jsonDecode(response.body);
    final List daily = data["daily"];

    return daily.map((d) {
      return {
        "day": DateFormat('EEE').format(
          DateTime.fromMillisecondsSinceEpoch(d["dt"] * 1000),
        ),
        "temp": d["temp"]["day"],
        "min": d["temp"]["min"],
        "max": d["temp"]["max"],
        "humidity": d["humidity"],
        "wind": d["wind_speed"] * 3.6, // Convert m/s to km/h
        "description": d["weather"][0]["main"],
        "icon": getWeatherIcon(d["weather"][0]["main"]),
      };
    }).toList();
  }

  /// ✅ Hourly forecast from OpenWeather
  Future<List<Map<String, dynamic>>> getHourlyForecast({
    required double lat,
    required double lon,
  }) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception("OpenWeather API key not found in .env");
    }

    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&exclude=current,minutely,daily,alerts&appid=$apiKey&units=metric",
    );

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch hourly forecast: ${response.body}");
    }

    final data = jsonDecode(response.body);
    final List hourly = data["hourly"];

    return hourly.take(24).map((h) {
      return {
        "time": DateFormat('HH:mm').format(
          DateTime.fromMillisecondsSinceEpoch(h["dt"] * 1000),
        ),
        "temp": h["temp"],
        "humidity": h["humidity"],
        "wind": h["wind_speed"] * 3.6, // Convert m/s to km/h
        "rain": (h["rain"]?["1h"] ?? 0).toDouble(),
        "icon": getWeatherIcon(h["weather"][0]["main"]),
      };
    }).toList();
  }

  /// ✅ AQI Data
  Future<Map<String, dynamic>> getAQIData({
    required double lat,
    required double lon,
  }) async {
    try {
      final url = "http://10.0.2.2:8000/get_aqi";
      final response = await http
          .post(
            Uri.parse(url),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"lat": lat, "lon": lon}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        throw Exception("Failed to fetch AQI");
      }

      final data = jsonDecode(response.body);
      return {"aqi": data["aqi"] ?? "--"};
    } catch (e) {
      debugPrint("Error fetching AQI: $e");
      return {"aqi": "--"};
    }
  }

  /// ✅ Anomalies (backend + fallback)
  Future<List<Map<String, dynamic>>> getAnomalies(
      double lat, double lon) async {
    try {
      final anomalyUrl = Uri.parse("http://10.0.2.2:8000/get_anomalies");
      final resp = await http
          .post(
            anomalyUrl,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"lat": lat, "lon": lon}),
          )
          .timeout(const Duration(seconds: 5));

      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        if (decoded is Map &&
            decoded['status'] == 'success' &&
            decoded['anomalies'] != null) {
          final list = <Map<String, dynamic>>[];
          for (final item in decoded['anomalies']) {
            list.add({
              "type": item['type'] ?? "Alert",
              "forecast": item['forecast']?.toString() ?? "",
              "time":
                  item['time']?.toString() ?? DateTime.now().toIso8601String(),
            });
          }
          if (list.isNotEmpty) return list;
        }
      }
    } catch (e) {
      debugPrint("getAnomalies backend error/fallback: $e");
    }

    // fallback local logic...
    try {
      final now =
          await getWeatherData(token: "dummy_token", lat: lat, lon: lon);
      final temp = (now['temperature'] ?? 0).toDouble();
      final rain = (now['rainfall'] ?? 0).toDouble();
      final humidity = (now['humidity'] ?? 0).toDouble();
      final wind = (now['wind_speed'] ?? 0).toDouble();

      final List<Map<String, dynamic>> results = [];

      if (rain > 20) {
        results.add({
          "type": "Heavy Rain",
          "forecast":
              "High chance of heavy rain (${rain.toStringAsFixed(1)} mm)",
          "time": DateTime.now().toLocal().toString(),
        });
      } else if (rain > 0) {
        results.add({
          "type": "Rain",
          "forecast": "Light to moderate rain expected",
          "time": DateTime.now().toLocal().toString(),
        });
      }

      if (temp >= 40) {
        results.add({
          "type": "Heat Alert",
          "forecast": "Extreme temperature: ${temp.toStringAsFixed(1)}°C",
          "time": DateTime.now().toLocal().toString(),
        });
      } else if (temp >= 35) {
        results.add({
          "type": "High Temp",
          "forecast": "Hot day: ${temp.toStringAsFixed(1)}°C",
          "time": DateTime.now().toLocal().toString(),
        });
      } else if (temp <= 2) {
        results.add({
          "type": "Cold Alert",
          "forecast": "Very low temperature: ${temp.toStringAsFixed(1)}°C",
          "time": DateTime.now().toLocal().toString(),
        });
      }

      if (wind >= 60) {
        results.add({
          "type": "Wind Storm",
          "forecast": "Very strong winds: ${wind.toStringAsFixed(1)} km/h",
          "time": DateTime.now().toLocal().toString(),
        });
      } else if (wind >= 30) {
        results.add({
          "type": "Strong Wind",
          "forecast": "Strong winds expected: ${wind.toStringAsFixed(1)} km/h",
          "time": DateTime.now().toLocal().toString(),
        });
      }

      if (humidity >= 95) {
        results.add({
          "type": "High Humidity",
          "forecast": "Very humid conditions: ${humidity.toStringAsFixed(0)}%",
          "time": DateTime.now().toLocal().toString(),
        });
      }

      if (results.isEmpty) {
        results.add({
          "type": "No Anomalies",
          "forecast": "No significant anomalies detected right now.",
          "time": DateTime.now().toLocal().toString(),
        });
      }

      return results;
    } catch (e) {
      debugPrint("getAnomalies fallback error: $e");
      return [
        {
          "type": "Unknown",
          "forecast": "Could not determine anomalies.",
          "time": DateTime.now().toLocal().toString(),
        },
      ];
    }
  }

  /// ✅ Radar / Weather Map Layer
  Future<Map<String, dynamic>> getRadarData(double lat, double lon) async {
    const String apiKey = "a5465304ed7d80bb3a52de825be8e7";

    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey",
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to fetch radar data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching radar data: $e");
      return {
        "status": "error",
        "message": e.toString(),
      };
    }
  }
}
