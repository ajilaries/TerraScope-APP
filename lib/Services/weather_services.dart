import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherService {
  final String apiKey = ""; // leave empty if you don’t use OpenWeather

  /// ✅ Fetch current weather from your backend
  Future<Map<String, dynamic>> getWeatherData({
    double? lat,
    double? lon,
  }) async {
    try {
      String url = "http://10.16.183.189:8000/weather";
      if (lat != null && lon != null) {
        url += "?lat=$lat&lon=$lon";
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is! Map) throw Exception("Backend did not return a Map");

        final temp = (data['temperature'] ?? 0).toDouble();
        final rain = (data['rainfall'] ?? 0).toDouble();

        String condition;
        if (rain > 0) {
          condition = "Rain";
        } else if (temp >= 30) {
          condition = "Clear";
        } else {
          condition = "Cloudy";
        }

        return {
          "temperature": temp,
          "rainfall": rain,
          "condition": condition,
        };
      }

      throw Exception("Failed to fetch weather");
    } catch (e) {
      debugPrint("WeatherService Error: $e");
      rethrow;
    }
  }

  /// ✅ Weather icon mapping
  IconData getWeatherIcon(String condition) {
    final c = condition.toLowerCase();
    if (c.contains("rain")) return WeatherIcons.rain;
    if (c.contains("cloud")) return WeatherIcons.cloudy;
    if (c.contains("clear")) return WeatherIcons.day_sunny;
    return WeatherIcons.na;
  }

  /// ✅ Background image
  String getBackgroundImage(String condition) {
    final c = condition.toLowerCase();
    if (c.contains("rain")) return "lib/assets/images/rainy.jpeg";
    if (c.contains("cloud")) return "lib/assets/images/cloudy.jpeg";
    if (c.contains("clear")) return "lib/assets/images/sunny.jpeg";
    return "lib/assets/images/default.jpg";
  }

  /// ✅ 5-Day Forecast (Simulated if no API key)
  Future<List<Map<String, dynamic>>> getFiveDayForecast(double lat, double lon) async {
    if (apiKey.isEmpty) {
      final current = await getWeatherData(lat: lat, lon: lon);
      final temp = current['temperature'];

      return List.generate(5, (i) {
        return {
          "day": DateFormat('EEE').format(DateTime.now().add(Duration(days: i + 1))),
          "temp": temp + i,
          "humidity": 55,
          "wind": 4.0,
          "icon": getWeatherIcon(current['condition']),
        };
      });
    }

    // ✅ REAL OpenWeather forecast
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric",
    );

    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception("Failed to load forecast");

    final data = json.decode(res.body);
    final List<dynamic> list = data["list"];
    final List<Map<String, dynamic>> forecast = [];
    final added = {};

    for (var item in list) {
      final dt = DateTime.parse(item["dt_txt"]);
      final day = DateFormat("EEE").format(dt);

      if (!added.containsKey(day) && dt.hour == 12) {
        forecast.add({
          "day": day,
          "temp": item["main"]["temp"].toDouble(),
          "humidity": item["main"]["humidity"],
          "wind": item["wind"]["speed"].toDouble(),
          "icon": getWeatherIcon(item["weather"][0]["main"]),
        });
        added[day] = true;
      }
    }

    return forecast;
  }

  /// ✅ Hourly Forecast (Simulated if no API key)
  Future<List<Map<String, dynamic>>> getHourlyForecast(
      double lat, double lon, DateTime day) async {
    if (apiKey.isEmpty) {
      final current = await getWeatherData(lat: lat, lon: lon);
      final temp = current['temperature'];

      return List.generate(24, (i) {
        return {
          "time": "${i.toString().padLeft(2, '0')}:00",
          "temp": temp,
          "humidity": 50,
          "wind": 3.5,
          "rain": 0,
          "icon": getWeatherIcon(current['condition']),
        };
      });
    }

    // ✅ REAL OpenWeather hourly
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric",
    );

    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception("Failed to load hourly forecast");

    final data = json.decode(res.body);
    final List<dynamic> list = data["list"];
    final List<Map<String, dynamic>> hourly = [];

    for (var item in list) {
      final dt = DateTime.parse(item["dt_txt"]);
      if (dt.year == day.year &&
          dt.month == day.month &&
          dt.day == day.day) {
        hourly.add({
          "time": DateFormat("HH:mm").format(dt),
          "temp": item["main"]["temp"].toDouble(),
          "humidity": item["main"]["humidity"],
          "wind": item["wind"]["speed"].toDouble(),
          "rain": item["rain"]?["3h"] ?? 0.0,
          "icon": getWeatherIcon(item["weather"][0]["main"]),
        });
      }
    }

    return hourly;
  }
}
