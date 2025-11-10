import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherService {
  final String apiKey = "a5465304ed7d80bb3a52de825be8e7"; // Only needed if fetching forecasts

  /// Fetch current weather from backend
  Future<Map<String, dynamic>> getWeatherData({
    double? lat,
    double? lon,
  }) async {
    try {
      String urlString = "http://192.168.43.7:8000/weather";
      if (lat != null && lon != null) {
        urlString += "?lat=$lat&lon=$lon";
      }

      final response = await http.get(Uri.parse(urlString));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final entry = data[0];
          final temperature = entry['temperature'] ?? 0.0;
          final rainfall = entry['rainfall'] ?? 0.0;
          String condition;
          if (rainfall > 0) {
            condition = "Rain";
          } else if (temperature >= 30) {
            condition = "Clear";
          } else {
            condition = "Cloudy";
          }

          return {
            "temperature": temperature,
            "rainfall": rainfall,
            "condition": condition,
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

  /// Map weather condition to icon
  IconData getWeatherIcon(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('rain') || c.contains('drizzle')) return WeatherIcons.rain;
    if (c.contains('cloud')) return WeatherIcons.cloudy;
    if (c.contains('clear') || c.contains('sun')) return WeatherIcons.day_sunny;
    if (c.contains('thunder') || c.contains('storm')) return WeatherIcons.thunderstorm;
    if (c.contains('snow')) return WeatherIcons.snow;
    if (c.contains('fog') || c.contains('mist')) return WeatherIcons.fog;
    return WeatherIcons.na;
  }

  /// Background image based on condition
  String getBackgroundImage(String condition) {
    final c = condition.toLowerCase();
    if (c.contains("rain") || c.contains("drizzle")) return "lib/assets/images/rainy.jpeg";
    if (c.contains("cloud")) return "lib/assets/images/cloudy.jpeg";
    if (c.contains("clear") || c.contains("sun")) return "lib/assets/images/sunny.jpeg";
    if (c.contains("storm") || c.contains("thunder")) return "lib/assets/images/storm.jpg";
    if (c.contains("fog") || c.contains("mist")) return "lib/assets/images/mist.jpg";
    return "lib/assets/images/default.jpg";
  }

  /// Fetch 5-day forecast (only works if OpenWeather API key is valid)
  Future<List<Map<String, dynamic>>> getFiveDayForecast(double lat, double lon) async {
    if (apiKey.isEmpty) {
      // If no API key, simulate 5-day forecast from current temperature
      final current = await getWeatherData(lat: lat, lon: lon);
      final temp = current['temperature'] ?? 25.0;
      return List.generate(5, (i) {
        return {
          "day": DateFormat('EEE').format(DateTime.now().add(Duration(days: i + 1))),
          "temp": temp + i, // simple simulation
          "humidity": 50,
          "wind": 5.0,
          "icon": getWeatherIcon(current['condition']),
        };
      });
    }

    // Fetch from OpenWeather if API key is valid
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric",
    );
    final response = await http.get(url);
    if (response.statusCode != 200) throw Exception("Failed to load 5-day forecast");

    final data = json.decode(response.body);
    final List<dynamic> list = data['list'];
    final List<Map<String, dynamic>> forecastList = [];
    final Map<String, bool> addedDays = {};

    for (var item in list) {
      final dateTime = DateTime.parse(item['dt_txt']);
      final dayStr = DateFormat('EEE').format(dateTime);

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

  /// Fetch hourly forecast for a day (simulated if API key is empty)
  Future<List<Map<String, dynamic>>> getHourlyForecast(double lat, double lon, DateTime day) async {
    if (apiKey.isEmpty) {
      final current = await getWeatherData(lat: lat, lon: lon);
      final temp = current['temperature'] ?? 25.0;
      return List.generate(24, (i) {
        return {
          "time": "${i.toString().padLeft(2, '0')}:00",
          "temp": temp,
          "humidity": 50,
          "wind": 5.0,
          "rain": 0.0,
          "icon": getWeatherIcon(current['condition']),
        };
      });
    }

    // Fetch from OpenWeather
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric",
    );
    final response = await http.get(url);
    if (response.statusCode != 200) throw Exception("Failed to load hourly forecast");

    final data = json.decode(response.body);
    final List<dynamic> list = data['list'];
    final List<Map<String, dynamic>> hourlyList = [];

    for (var item in list) {
      final dateTime = DateTime.parse(item['dt_txt']);
      if (dateTime.year == day.year && dateTime.month == day.month && dateTime.day == day.day) {
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
