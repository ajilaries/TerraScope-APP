import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✅ Correct package for DateFormat
import '../Services/location_service.dart';
import '../Services/weather_services.dart';
import '../Widgets/footer_buttons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String locationName = "Loading...";
  String temperature = "---°C";
  String weatherCondition = "Fetching...";
  String weatherIcon = "☁️";
  String day = "";
  String time = "";

  @override
  void initState() {
    super.initState();
    updateDateTime();
    fetchWeatherData();
  }

  void updateDateTime() {
    final now = DateTime.now();
    day = DateFormat('EEE, MMM d').format(now);
    time = DateFormat('hh:mm a').format(now);
  }

  Future<void> fetchWeatherData() async {
    try {
      final position = await LocationService().getCurrentLocation();
      final weatherData = await WeatherService().getWeatherData(
        position.latitude,
        position.longitude,
      );

      setState(() {
        locationName = weatherData['name'] ?? "Unknown";
        temperature =
            "${weatherData['main']['temp'].toStringAsFixed(1)}°C";
        weatherCondition = weatherData['weather'][0]['description'];
        weatherIcon = WeatherService().getWeatherIcon(
          weatherData['weather'][0]['main'],
        );
      });
    } catch (e) {
      setState(() {
        locationName = "Location Error";
        weatherCondition = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "TerraScope",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'lib/assets/logo.jpg', // ✅ Make sure this path matches your asset
              height: 36,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ✅ Background image based on weather
          Positioned.fill(
            child: Image.asset(
              WeatherService().getBackgroundImage(weatherCondition),
              fit: BoxFit.cover,
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    locationName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "$day · $time",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  Text(weatherIcon, style: const TextStyle(fontSize: 80)),
                  Text(
                    temperature,
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    weatherCondition.toUpperCase(),
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const Spacer(),
                  const FooterButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
