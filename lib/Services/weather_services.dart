import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherService {
  final String apiKey = "a5465304ed7d80bb3a52de825be8e7";

  /// ✅ Fetch current weather from backend for optional coordinates
  Future<Map<String, dynamic>> getWeatherData({
    double? lat,
    double? lon,
  }) async {
    try {
      String urlString = "http://192.168.43.7:8000/weather";
      // Pass coordinates as query params if provided
      if (lat != null && lon != null) {
        urlString += "?lat=$lat&lon=$lon";
      }

      final response = await http.get(Uri.parse(urlString));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          // 🔹 Backend sends [{"temperature":23.31,"rainfall":0}]
          final entry = data[0];

          // Map your backend JSON to a more standard structure
          final temperature = entry['temperature'] ?? 0.0;
          final rainfall = entry['rainfall'] ?? 0.0;
          String condition;

          if (rainfall > 0) {
            condition = "Rain";
          } else if (temperature >= 30) {
            condition = "Clear"; // sunny
          } else {
            condition = "Cloudy";
          }

          return {
            "temperature": temperature,
            "rainfall": rainfall,
            "condition": condition, // add a condition key
          };
        }
        throw Exception("Backend returned empty weather data");
      } else {
        throw Exception("Failed to fetch weather data");
      }
    } catch (e) {
      debugPrint("WeatherService Error: $e");
      rethrow;
    }
  }

  /// ✅ Map weather condition to icon
  IconData getWeatherIcon(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('rain') || c.contains('drizzle')) return WeatherIcons.rain;
    if (c.contains('cloud')) return WeatherIcons.cloudy;
    if (c.contains('clear') || c.contains('sun')) return WeatherIcons.day_sunny;
    if (c.contains('thunder') || c.contains('storm')) {
      return WeatherIcons.thunderstorm;
    }
    if (c.contains('snow')) return WeatherIcons.snow;
    if (c.contains('fog') || c.contains('mist')) return WeatherIcons.fog;
    return WeatherIcons.na;
  }

  /// ✅ Get background image based on weather
  String getBackgroundImage(String condition) {
    final c = condition.toLowerCase();
    if (c.contains("rain") || c.contains("drizzle")) {
      return "lib/assets/images/rainy.jpeg";
    }
    if (c.contains("cloud")) return "assets/images/cloudy.jpeg";
    if (c.contains("clear") || c.contains("sun")) {
      return "lib/assets/images/sunny.jpeg";
    }
    if (c.contains("storm") || c.contains("thunder")) {
      return "lib/assets/images/storm.jpg";
    }
    if (c.contains("fog") || c.contains("mist")) {
      return "lib/assets/images/mist.jpg";
    }
    return "lib/assets/images/default.jpg";
  }

  /// ✅ Fetch 5-day forecast using OpenWeather API
  Future<List<Map<String, dynamic>>> getFiveDayForecast(
    double lat,
    double lon,
  ) async {
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric",
    );
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception("Failed to load 5-day forecast");
    }

    final data = json.decode(response.body);
    final List<dynamic> list = data['list'];
    final List<Map<String, dynamic>> forecastList = [];
    final Map<String, bool> addedDays = {};

    for (var item in list) {
      final dateTime = DateTime.parse(item['dt_txt']);
      final dayStr = DateFormat('EEE').format(dateTime);

      // Pick one forecast per day at 12 PM
      if (!addedDays.containsKey(dayStr) && dateTime.hour == 12) {
        forecastList.add({
          'day': dayStr,
          'temp': item['main']['temp'].toDouble(),
          'humidity': item['main']['humidity'],
          'wind': item['wind']['speed'].toDouble(),
          'icon': getWeatherIcon(item['weather'][0]['main']),
        });
        addedDays[dayStr] = true;
      }
    }
    return forecastList;
  }

  /// ✅ Fetch hourly forecast for a given day
  Future<List<Map<String, dynamic>>> getHourlyForecast(
    double lat,
    double lon,
    DateTime day,
  ) async {
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric",
    );
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception("Failed to load hourly forecast");
    }

    final data = json.decode(response.body);
    final List<dynamic> list = data['list'];
    final List<Map<String, dynamic>> hourlyList = [];

    for (var item in list) {
      final dateTime = DateTime.parse(item['dt_txt']);
      if (dateTime.year == day.year &&
          dateTime.month == day.month &&
          dateTime.day == day.day) {
        hourlyList.add({
          'time': DateFormat('HH:mm').format(dateTime),
          'temp': item['main']['temp'].toDouble(),
          'humidity': item['main']['humidity'],
          'wind': item['wind']['speed'].toDouble(),
          'rain': item['rain'] != null ? (item['rain']['3h'] ?? 0.0) : 0.0,
          'icon': getWeatherIcon(item['weather'][0]['main']),
        });
      }
    }

    return hourlyList;
  }
}
