import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';
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
  IconData weatherIcon = WeatherIcons.cloud;
  String day = "";
  String time = "";
  String lastUpdated = "—"; // ✅ new variable for last updated time
  bool isRefreshing = false;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    updateDateTime();
    fetchWeatherData();
    startAutoRefresh();
  }

  void updateDateTime() {
    final now = DateTime.now();
    day = DateFormat('EEE, MMM d').format(now);
    time = DateFormat('hh:mm a').format(now);
  }

  void startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      fetchWeatherData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchWeatherData() async {
    try {
      setState(() => isRefreshing = true);

      final locationData = await LocationService().getCurrentLocation();
      final weatherData = await WeatherService().getWeatherData(
        locationData['latitude'],
        locationData['longitude'],
      );

      final now = DateTime.now();

      setState(() {
        locationName =
            "${locationData['city']}, ${locationData['country']}".trim();
        temperature = "${weatherData['main']['temp'].toStringAsFixed(1)}°C";
        weatherCondition = weatherData['weather'][0]['description'];
        weatherIcon =
            WeatherService().getWeatherIcon(weatherData['weather'][0]['main']);
        updateDateTime();
        lastUpdated = DateFormat('hh:mm a').format(now); // ✅ show last update time
        isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        locationName = "Location Error";
        weatherCondition = e.toString();
        isRefreshing = false;
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
          IconButton(
            icon: isRefreshing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: isRefreshing ? null : fetchWeatherData,
          ),
        ],
      ),
      body: Stack(
        children: [
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
                    textAlign: TextAlign.center,
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
                  Icon(
                    weatherIcon,
                    size: 80,
                    color: Colors.white,
                  ),
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
                  const SizedBox(height: 12),

                  // ✅ "Last updated" text
                  Text(
                    "Last updated: $lastUpdated",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
