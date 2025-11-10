import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';
import '../Services/location_service.dart';
import '../Services/weather_services.dart';

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

  String latitude = "--";
  String longitude = "--";

  String day = "";
  String time = "";
  String lastUpdated = "—";
  bool isRefreshing = false;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _fetchWeatherData();
    _startAutoRefresh();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    day = DateFormat('EEE, MMM d').format(now);
    time = DateFormat('hh:mm a').format(now);
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _fetchWeatherData(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchWeatherData() async {
    setState(() => isRefreshing = true);

    try {
      // 1️⃣ Get location
      final loc = await LocationService().getCurrentLocation();
      final lat = loc["latitude"];
      final lon = loc["longitude"];
      locationName = "${loc['city'] ?? 'Unknown City'}, ${loc['country'] ?? 'Unknown'}";
      latitude = lat.toStringAsFixed(4);
      longitude = lon.toStringAsFixed(4);

      // 2️⃣ Get weather from backend
      final latest = await WeatherService().getWeatherData(lat: lat, lon: lon);

      // 3️⃣ Decide condition from backend JSON
      final temp = latest['temperature'] ?? 0;
      final rainfall = latest['rainfall'] ?? 0;
      final condition = rainfall > 0 ? "Rain" : "Clear";

      setState(() {
        temperature = "${temp.toStringAsFixed(1)}°C";
        weatherCondition = condition;
        weatherIcon = WeatherService().getWeatherIcon(condition);
        lastUpdated = DateFormat('hh:mm a').format(DateTime.now());
      });
    } catch (e) {
      debugPrint("❌ ERROR: $e");
      setState(() {
        locationName = "Location / Weather Error";
        latitude = "--";
        longitude = "--";
        temperature = "---°C";
        weatherCondition = "Unknown";
        weatherIcon = WeatherIcons.na;
        lastUpdated = "—";
      });
    } finally {
      setState(() => isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgImage = WeatherService().getBackgroundImage(weatherCondition);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("TerraScope", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          IconButton(
            icon: isRefreshing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: isRefreshing ? null : _fetchWeatherData,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset(bgImage, fit: BoxFit.cover)),
          Container(color: Colors.black.withOpacity(0.3)),
          SafeArea(
            child: RefreshIndicator(
              color: Colors.white,
              onRefresh: _fetchWeatherData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 40),
                  Text(
                    locationName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Lat: $latitude   |   Lon: $longitude",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "$day · $time",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // ⚡ Prevent overflow
                      children: [
                        Icon(weatherIcon, size: 80, color: Colors.white),
                        Text(
                          temperature,
                          style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          weatherCondition.toUpperCase(),
                          style: const TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Last updated: $lastUpdated",
                          style: const TextStyle(fontSize: 14, color: Colors.white60),
                        ),
                      ],
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
