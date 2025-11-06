import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherService {
  final String apiKey = "a5465304ed7d80bb3a52de825be8e2e7";

  // Fetch current weather data
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

  // Fetch 5-day forecast
Future<List<Map<String, dynamic>>> getFiveDayForecast(double lat, double lon) async {
  final url = Uri.parse(
    "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric"
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List<Map<String, dynamic>> forecastList = [];
    final List<dynamic> list = data['list'];
    final Map<String, bool> addedDays = {};

    for (var item in list) {
      final dateTime = DateTime.parse(item['dt_txt']);
      final dayStr = DateFormat('EEE').format(dateTime);

      // pick only one forecast per day (around 12:00 PM)
      if (!addedDays.containsKey(dayStr) && dateTime.hour == 12) {
        forecastList.add({
          'day': dayStr,
          'temp': item['main']['temp'].toDouble(),
          'humidity': item['main']['humidity'],            // ✅ humidity
          'wind': item['wind']['speed'].toDouble(),       // ✅ wind speed
          'icon': getWeatherIcon(item['weather'][0]['main']),
        });
        addedDays[dayStr] = true;
      }
    }

    return forecastList;
  } else {
    throw Exception("Failed to load 5-day forecast");
  }
}
//fetch hourly forecast for a specfic day
Future<List<Map<String ,dynamic>>> getHourlyForecast(double lat,double lon, DateTime day)async {
  final url=Uri.parse(
    "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric"
  );
  final respose=await http.get(url);

  if(respose.statusCode==200){
    final data=json.decode(respose.body);
    final List<dynamic> list=data['list'];
    final List<Map<String,dynamic>> hourlyList=[];

    for(var item in list){
      final dateTime =DateTime.parse(item['dt_text']);
      if(dateTime.year==day.year&& dateTime.month==day.month && dateTime.day==day.day){
        hourlyList.add({
          'time':DateFormat('HH:mm').format(dateTime),
          'temp':item['main']['temp'].toDouble(),
          'humidity': item['main']['humidity'],
          'wind': item['wind']['speed'].toDouble(),
          'rain': item['rain'] != null ? item['rain']['3h'] ?? 0.0 : 0.0,
          'icon': getWeatherIcon(item['weather'][0]['main']),

        });
      }
    }
    return hourlyList;
  }else{
    throw Exception("failed to load hourly forecast");
  }
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
      return 'lib/assets/images/default.jpg';
    }
  }

