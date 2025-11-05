import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_icons/weather_icons.dart';

class WeatherService {
  final String apiKey = "a5465304ed7d80bb3a52de825be8e2e7";

  // Fetch weather data from OpenWeather API
  Future<Map<String, dynamic>> getWeatherData(double lat, double lon) async {
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric",
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load weather data");
    }
  }

  // Return proper weather icon based on condition
  IconData getWeatherIcon(String condition) {
    condition = condition.toLowerCase();

    if (condition.contains('rain')) {
      return WeatherIcons.rain;
    } else if (condition.contains('cloud')) {
      return WeatherIcons.cloudy;
    } else if (condition.contains('clear')) {
      return WeatherIcons.day_sunny;
    } else if (condition.contains('thunder')) {
      return WeatherIcons.thunderstorm;
    } else if (condition.contains('snow')) {
      return WeatherIcons.snow;
    } else if (condition.contains('mist') || condition.contains('fog')) {
      return WeatherIcons.fog;
    } else {
      return WeatherIcons.na; // fallback if condition doesn't match
    }
  }

  // Return background image based on condition
  String getBackgroundImage(String condition) {
    condition = condition.toLowerCase();

    if (condition.contains('clear')) {
      return 'lib/assets/images/sunny.jpeg';
    } else if (condition.contains('cloud')) {
      return 'lib/assets/images/cloudy.jpeg';
    } else if (condition.contains('rain')) {
      return 'lib/assets/images/rainy.jpeg';
    } else if (condition.contains('storm') || condition.contains('thunder')) {
      return 'lib/assets/images/storm.jpg';
    } else if (condition.contains('snow')) {
      return 'lib/assets/images/snow.png';
    } else if (condition.contains('mist') || condition.contains('fog')) {
      return 'lib/assets/images/mist.png';
    } else {
      return 'lib/assets/images/default.png';
    }
  }
}
