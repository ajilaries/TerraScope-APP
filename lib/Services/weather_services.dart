import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = "YOUR_OPENWEATHER_API_KEY";

  Future<Map<String, dynamic>> getWeatherData(double lat, double lon) async {
    const String appid = 'YOUR_API_KEY_HERE'; // Replace with your real key
  const String units = 'metric'; // or 'imperial' for Fahrenheit
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?lat=?lat&long=$lon$appid=$apiKey$units=metric",
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("failed to load the weather data");
    }
  }

  String getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'rain':
        return 'rain here';
      case 'clouds':
        return 'cloudy climate';
      case 'clear':
        return 'clear climate';
      case 'thunderstrom':
        return 'thunderstrom';
      case 'snow':
        return 'snow';
      default:
        return 'rainbow';
    }
  }

  String getBackgroundImage(String condition) {
    if (condition.contains('rain')) return "assets/images/rainy.png";
    if (condition.contains("cloud")) return "assets/images/cloudy.jpg";
    if (condition.contains("clear")) return "assets/images/sunny.jpg";
    if (condition.contains("snow")) return "assets/images/snowy.jpg";
    return "assets/images/default.png";
  }
}
