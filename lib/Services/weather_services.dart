import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  static Future<Map<String, dynamic>?> getCurrentWeather(
      double lat, double lon) async {
    try {
      final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
      if (apiKey == null) return null;

      final url = Uri.parse(
          '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching weather: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getWeatherForecast(
      double lat, double lon) async {
    try {
      final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
      if (apiKey == null) return null;

      final url = Uri.parse(
          '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching forecast: $e');
      return null;
    }
  }

  static Map<String, dynamic> parseWeatherData(Map<String, dynamic> data) {
    return {
      'temperature': data['main']['temp'],
      'humidity': data['main']['humidity'],
      'windSpeed': data['wind']['speed'],
      'visibility': data['visibility'] ?? 10000,
      'rainMm': data['rain']?['1h'] ?? 0.0,
      'description': data['weather'][0]['description'],
      'icon': data['weather'][0]['icon'],
    };
  }

  static Future<List<Map<String, dynamic>>> getAnomalies(
      double lat, double lon) async {
    // Mock implementation - replace with actual API call
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return [
      {
        'type': 'Heavy Rain Alert',
        'forecast': 'Heavy rainfall expected in the next 2 hours',
        'time': '2 hours',
      },
      {
        'type': 'High Wind Warning',
        'forecast': 'Winds up to 30 km/h expected',
        'time': '1 hour',
      },
    ];
  }

  static Future<Map<String, dynamic>?> getWeatherData(
      double lat, double lon) async {
    return await getCurrentWeather(lat, lon);
  }

  static Future<List<Map<String, dynamic>>> getHourlyForecast(
      double lat, double lon) async {
    try {
      final forecastData = await getWeatherForecast(lat, lon);
      if (forecastData == null || forecastData['list'] == null) return [];

      final list = forecastData['list'] as List;
      return list.take(8).map((item) {
        final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
        return {
          'time': '${dt.hour.toString().padLeft(2, '0')}:00',
          'temp': (item['main']['temp'] as num).toDouble(),
          'wind': (item['wind']['speed'] as num).toDouble(),
          'rain': item['rain']?['3h'] ?? 0.0,
        };
      }).toList();
    } catch (e) {
      print('Error fetching hourly forecast: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getAQIData(
      double lat, double lon) async {
    // Mock AQI data - replace with actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'aqi': 45,
      'pm25': 12.5,
      'pm10': 25.0,
      'o3': 30.0,
      'no2': 15.0,
      'so2': 5.0,
      'co': 0.5,
    };
  }

  static String getWeatherIcon(String iconCode) {
    // Map OpenWeather icon codes to weather icons
    switch (iconCode) {
      case '01d':
        return '☀️';
      case '01n':
        return '🌙';
      case '02d':
      case '02n':
        return '⛅';
      case '03d':
      case '03n':
        return '☁️';
      case '04d':
      case '04n':
        return '☁️';
      case '09d':
      case '09n':
        return '🌧️';
      case '10d':
      case '10n':
        return '🌦️';
      case '11d':
      case '11n':
        return '⛈️';
      case '13d':
      case '13n':
        return '❄️';
      case '50d':
      case '50n':
        return '🌫️';
      default:
        return '☀️';
    }
  }

  static String getBackgroundImage(String condition) {
    // Return asset path based on weather condition
    if (condition.toLowerCase().contains('rain')) {
      return 'lib/assets/images/rainy.jpeg';
    } else if (condition.toLowerCase().contains('cloud')) {
      return 'lib/assets/images/cloudy.jpeg';
    } else if (condition.toLowerCase().contains('clear')) {
      return 'lib/assets/images/sunny.jpeg';
    } else if (condition.toLowerCase().contains('mist') ||
        condition.toLowerCase().contains('fog')) {
      return 'lib/assets/images/mist.jpg';
    } else if (condition.toLowerCase().contains('storm')) {
      return 'lib/assets/images/strom.jpg';
    } else {
      return 'lib/assets/images/default.jpg';
    }
  }

  static Future<Map<String, dynamic>?> getRadarData(
      double lat, double lon) async {
    // Mock radar data - replace with actual radar API
    await Future.delayed(const Duration(seconds: 1));
    return {
      'radarImageUrl': 'https://example.com/radar.png',
      'precipitation': 2.5,
      'intensity': 'moderate',
    };
  }
}
