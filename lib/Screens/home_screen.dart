// {"id":"45913","variant":"standard","title":"Corrected MainHomeScreen with live updates"}
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import '../Services/location_service.dart';
import '../Services/weather_services.dart';
import '../Services/notification_service.dart';
import '../providers/mode_provider.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  String city = "Fetching location...";
  String condition = "—";
  String temp = "—°C";
  int aqi = 0;
  List<Map<String, dynamic>> forecast7 = [];
  List<Map<String, dynamic>> forecast24 = [];
  bool isLoading = true;

  final WeatherService weatherService = WeatherService();
  Timer? autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
    autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchHomeData(autoRefresh: true);
    });
  }

  @override
  void dispose() {
    autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<String> _getCityName(double lat, double lon) async {
    try {
      List<Placemark> place = await placemarkFromCoordinates(lat, lon);
      if (place.isNotEmpty) return place.first.locality ?? "Unknown";
      return "Unknown";
    } catch (e) {
      return "Unknown";
    }
  }

  Future<void> _fetchHomeData({bool autoRefresh = false}) async {
    if (!autoRefresh) setState(() => isLoading = true);

    try {
      // 🔥 Get fresh high-accuracy location
      final loc = await LocationService().getCurrentLocation();
      await LocationService().updateDeviceLocationToBackend();

      final lat = loc["latitude"];
      final lon = loc["longitude"];

      final token = await NotificationService.getDeviceToken() ?? "";

      // 🔥 Fetch weather
      final weather = await weatherService.getWeatherData(
        token: token,
        lat: lat,
        lon: lon,
      );

      // 🔥 Fetch AQI separately
      final aqiData = await weatherService.getAQIData(lat: lat, lon: lon);

      String cityName = await _getCityName(lat, lon);

      if (!mounted) return;
      setState(() {
        city = cityName;
        temp = "${weather["temperature"]?.toStringAsFixed(1) ?? '--'}°C";
        condition = weather["condition"] ?? "_";
        aqi = aqiData['aqi'] ?? 40;
        forecast7 = weather["forecast7"] ?? [];
        forecast24 = weather["forecast24"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching home data: $e");
      if (mounted)
        setState(() {
          temp = "—°C";
          condition = "Error";
          isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ModeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Terrascope Pro",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.brightness_6,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () =>
                Provider.of<ModeProvider>(context, listen: false).toggleTheme(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _fetchHomeData(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _currentWeatherCard(isDark),
                  const SizedBox(height: 20),
                  _forecast7Card(isDark),
                  const SizedBox(height: 20),
                  _forecast24Card(isDark),
                  const SizedBox(height: 20),
                  _metricsGrid(isDark),
                  const SizedBox(height: 20),
                  _aqiCard(isDark),
                ],
              ),
            ),
    );
  }

  // ---------------- UI Widgets ----------------
  Widget _currentWeatherCard(bool dark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxDecoration(dark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(city,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: dark ? Colors.white : Colors.black)),
          Text(DateFormat('EEE, MMM d • hh:mm a').format(DateTime.now()),
              style: TextStyle(color: dark ? Colors.white54 : Colors.black54)),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(temp,
                  style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: dark ? Colors.white : Colors.black)),
              const SizedBox(width: 15),
              Text(condition,
                  style: TextStyle(
                      fontSize: 20, color: dark ? Colors.white70 : Colors.black87))
            ],
          ),
        ],
      ),
    );
  }

  Widget _forecast7Card(bool dark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _boxDecoration(dark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("7-Day Forecast",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: dark ? Colors.white : Colors.black)),
          const SizedBox(height: 10),
          SizedBox(
            height: 105,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: forecast7.length,
              itemBuilder: (_, i) {
                return Container(
                  width: 80,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(right: 12),
                  decoration: _smallBox(dark),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(forecast7[i]["day"],
                          style: TextStyle(color: dark ? Colors.white70 : Colors.black87)),
                      const SizedBox(height: 5),
                      Icon(Icons.cloud_queue, color: dark ? Colors.white : Colors.black),
                      const SizedBox(height: 5),
                      Text("${forecast7[i]["max"]}° / ${forecast7[i]["min"]}°",
                          style: TextStyle(color: dark ? Colors.white : Colors.black)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _forecast24Card(bool dark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _boxDecoration(dark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Next 24 Hours",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: dark ? Colors.white : Colors.black)),
          const SizedBox(height: 10),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: forecast24.length,
              itemBuilder: (_, i) {
                return Container(
                  width: 75,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(right: 12),
                  decoration: _smallBox(dark),
                  child: Column(
                    children: [
                      Text(forecast24[i]["time"],
                          style: TextStyle(color: dark ? Colors.white : Colors.black)),
                      const SizedBox(height: 5),
                      Icon(Icons.cloud, color: dark ? Colors.white : Colors.black),
                      const SizedBox(height: 5),
                      Text("${forecast24[i]["temp"]}°",
                          style: TextStyle(color: dark ? Colors.white : Colors.black)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricsGrid(bool dark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _metric("Humidity", "62%", dark),
        _metric("Wind", "12 km/h", dark),
        _metric("Pressure", "1008 hPa", dark),
        _metric("Visibility", "8 km", dark),
      ],
    );
  }

  Widget _metric(String label, String value, bool dark) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: dark ? Colors.white : Colors.black)),
        Text(label, style: TextStyle(color: dark ? Colors.white70 : Colors.black87)),
      ],
    );
  }

  Widget _aqiCard(bool dark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxDecoration(dark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Air Quality Index",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: dark ? Colors.white : Colors.black)),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.orange,
                child: Text("$aqi", style: const TextStyle(fontSize: 22, color: Colors.white)),
              ),
              const SizedBox(width: 15),
              Text("Moderate air quality today.",
                  style: TextStyle(color: dark ? Colors.white70 : Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration(bool dark) =>
      BoxDecoration(color: dark ? Colors.white10 : Colors.grey.shade100, borderRadius: BorderRadius.circular(18));

  BoxDecoration _smallBox(bool dark) =>
      BoxDecoration(color: dark ? Colors.white12 : Colors.grey.shade200, borderRadius: BorderRadius.circular(14));
}
