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
    try {
      final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
      if (apiKey == null) return [];

      // Use One Call API 3.0 for weather alerts
      final url = Uri.parse(
          'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&exclude=minutely,hourly,daily&appid=$apiKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final alerts = data['alerts'] as List? ?? [];

        return alerts.map((alert) {
          return {
            'type': alert['event'] ?? 'Weather Alert',
            'forecast': alert['description'] ?? 'Weather alert issued',
            'time': _formatAlertTime(alert['start'], alert['end']),
          };
        }).toList();
      }

      // Fallback to current weather analysis if alerts API fails
      final weatherData = await getCurrentWeather(lat, lon);
      if (weatherData != null) {
        final parsed = parseWeatherData(weatherData);
        final anomalies = <Map<String, dynamic>>[];

        if ((parsed['rainMm'] as num) > 10) {
          anomalies.add({
            'type': 'Heavy Rain Alert',
            'forecast': 'Heavy rainfall detected (${parsed['rainMm']}mm)',
            'time': 'Current',
          });
        }

        if ((parsed['windSpeed'] as num) > 20) {
          anomalies.add({
            'type': 'High Wind Warning',
            'forecast': 'Strong winds detected (${parsed['windSpeed']} km/h)',
            'time': 'Current',
          });
        }

        if ((parsed['visibility'] as num) < 1000) {
          anomalies.add({
            'type': 'Poor Visibility',
            'forecast': 'Reduced visibility (${parsed['visibility']}m)',
            'time': 'Current',
          });
        }

        return anomalies;
      }

      return [];
    } catch (e) {
      print('Error fetching anomalies: $e');
      return [];
    }
  }

  static String _formatAlertTime(int? start, int? end) {
    if (start == null || end == null) return 'Unknown';

    final startTime = DateTime.fromMillisecondsSinceEpoch(start * 1000);
    final endTime = DateTime.fromMillisecondsSinceEpoch(end * 1000);
    final now = DateTime.now();

    if (startTime.isAfter(now)) {
      final hours = startTime.difference(now).inHours;
      return 'In $hours hours';
    } else if (endTime.isAfter(now)) {
      final hours = endTime.difference(now).inHours;
      return '$hours hours remaining';
    } else {
      return 'Expired';
    }
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
    try {
      final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
      if (apiKey == null) return null;

      final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final components = data['list'][0]['components'];
        final aqi = data['list'][0]['main']['aqi'];

        return {
          'aqi': aqi,
          'pm25': components['pm2_5'] ?? 0.0,
          'pm10': components['pm10'] ?? 0.0,
          'o3': components['o3'] ?? 0.0,
          'no2': components['no2'] ?? 0.0,
          'so2': components['so2'] ?? 0.0,
          'co': components['co'] ?? 0.0,
        };
      }
      return null;
    } catch (e) {
      print('Error fetching AQI data: $e');
      return null;
    }
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
    try {
      // Use RainViewer API for real radar data
      final radarUrl =
          Uri.parse('https://api.rainviewer.com/public/weather-maps.json');
      final radarResponse = await http.get(radarUrl);

      if (radarResponse.statusCode == 200) {
        final radarData = json.decode(radarResponse.body);
        final radarList = radarData['radar'] as List;

        if (radarList.isNotEmpty) {
          final latestRadar = radarList.last;
          final radarImageUrl =
              'https://tilecache.rainviewer.com${latestRadar['path']}/512/4/${lat.round()}/${lon.round()}/1/1_1.png';

          // Get current weather for precipitation data
          final weatherData = await getCurrentWeather(lat, lon);
          final precipitation = weatherData?['rain']?['1h'] ?? 0.0;
          final intensity = _getPrecipitationIntensity(precipitation);

          return {
            'radarImageUrl': radarImageUrl,
            'precipitation': precipitation,
            'intensity': intensity,
            'timestamp': latestRadar['time'],
          };
        }
      }

      // Fallback to current weather analysis
      final weatherData = await getCurrentWeather(lat, lon);
      if (weatherData != null) {
        final precipitation = weatherData['rain']?['1h'] ?? 0.0;
        final intensity = _getPrecipitationIntensity(precipitation);

        return {
          'radarImageUrl': null, // No radar image available
          'precipitation': precipitation,
          'intensity': intensity,
          'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        };
      }

      return null;
    } catch (e) {
      print('Error fetching radar data: $e');
      return null;
    }
  }

  static String _getPrecipitationIntensity(double precipitation) {
    if (precipitation >= 7.6) return 'heavy';
    if (precipitation >= 2.5) return 'moderate';
    if (precipitation >= 0.1) return 'light';
    return 'none';
  }
}
