// {"id":"45913","variant":"standard","title":"Corrected MainHomeScreen with live updates"}
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terra_scope_apk/pages/ai_predict_page.dart';
import '../Services/location_service.dart';
import '../Services/weather_services.dart';
import '../providers/mode_provider.dart';
import 'radar_screen.dart';
import 'anomalies_screen.dart';
import 'forecast_dashboard.dart';

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
  double currentLat = 0.0;
  double currentLon = 0.0;
  List<Map<String, dynamic>> forecast7 = [];
  List<Map<String, dynamic>> forecast24 = [];
  bool isLoading = true;
  int humidity = 0;
  double windSpeed = 0.0;
  int pressure = 0;
  int visibility = 0;

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
      final position = await LocationService.getCurrentPosition();
      if (position == null) {
        setState(() => isLoading = false);
        return;
      }

      currentLat = position.latitude;
      currentLon = position.longitude;

      // 🔥 Fetch current weather
      final currentWeather =
          await WeatherService.getCurrentWeather(currentLat, currentLon);
      final forecastData =
          await WeatherService.getWeatherForecast(currentLat, currentLon);

      String cityName = await _getCityName(currentLat, currentLon);

      if (!mounted) return;

      // Parse forecast data
      List<Map<String, dynamic>> parsedForecast7 = [];
      List<Map<String, dynamic>> parsedForecast24 = [];

      if (forecastData != null && forecastData['list'] != null) {
        final list = forecastData['list'] as List;
        // 7-day forecast (every 24 hours)
        for (int i = 0; i < 7 && i * 8 < list.length; i++) {
          final item = list[i * 8];
          final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          parsedForecast7.add({
            'day': DateFormat('EEE').format(dt),
            'max': (item['main']['temp_max'] as num).toDouble(),
            'min': (item['main']['temp_min'] as num).toDouble(),
          });
        }
        // 24-hour forecast (every 3 hours)
        for (int i = 0; i < list.length && i < 8; i++) {
          final item = list[i];
          final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          parsedForecast24.add({
            'time': DateFormat('HH:mm').format(dt),
            'temp': (item['main']['temp'] as num).toDouble(),
          });
        }
      }

      setState(() {
        city = cityName;
        temp = currentWeather != null
            ? "${currentWeather['main']['temp'].toStringAsFixed(1)}°C"
            : "—°C";
        condition = currentWeather != null
            ? currentWeather['weather'][0]['description']
            : "_";
        humidity = currentWeather != null
            ? (currentWeather['main']['humidity'] as num).toInt()
            : 0;
        windSpeed = currentWeather != null
            ? (currentWeather['wind']['speed'] as num).toDouble()
            : 0.0;
        pressure = currentWeather != null
            ? (currentWeather['main']['pressure'] as num).toInt()
            : 0;
        visibility = currentWeather != null
            ? (currentWeather['visibility'] as num).toInt()
            : 0;
        aqi = 40; // Mock AQI since no API
        forecast7 = parsedForecast7;
        forecast24 = parsedForecast24;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching home data: $e");
      if (mounted) {
        setState(() {
          temp = "—°C";
          condition = "Error";
          isLoading = false;
        });
      }
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
          "Terrascope",
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
          IconButton(
            icon: const Icon(
              Icons.auto_awesome,
              color: Colors.deepPurple,
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AIPredictPage(lat: currentLat, lon: currentLon),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.shield,
              color: Colors.red,
              size: 28,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/safety-mode');
            },
          ),
          const SizedBox(width: 10),
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
                  const SizedBox(height: 20),
                  _quickAccessGrid(isDark),
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
          Text(
            city,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: dark ? Colors.white : Colors.black,
            ),
          ),
          Text(
            DateFormat('EEE, MMM d • hh:mm a').format(DateTime.now()),
            style: TextStyle(color: dark ? Colors.white54 : Colors.black54),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                temp,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: dark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 15),
              Flexible(
                child: Text(
                  condition,
                  style: TextStyle(
                    fontSize: 20,
                    color: dark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
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
          Text(
            "7-Day Forecast",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: dark ? Colors.white : Colors.black,
            ),
          ),
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
                      Text(
                        forecast7[i]["day"],
                        style: TextStyle(
                          color: dark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Icon(
                        Icons.cloud_queue,
                        color: dark ? Colors.white : Colors.black,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${forecast7[i]["max"]}° / ${forecast7[i]["min"]}°",
                        style: TextStyle(
                          color: dark ? Colors.white : Colors.black,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
          Text(
            "Next 24 Hours",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: dark ? Colors.white : Colors.black,
            ),
          ),
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
                      Text(
                        forecast24[i]["time"],
                        style: TextStyle(
                          color: dark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Icon(
                        Icons.cloud,
                        color: dark ? Colors.white : Colors.black,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${forecast24[i]["temp"]}°",
                        style: TextStyle(
                          color: dark ? Colors.white : Colors.black,
                        ),
                      ),
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
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.spaceAround,
      children: [
        _metric("Humidity", "$humidity%", dark),
        _metric("Wind", "${windSpeed.toStringAsFixed(1)} km/h", dark),
        _metric("Pressure", "$pressure hPa", dark),
        _metric(
            "Visibility", "${(visibility / 1000).toStringAsFixed(1)} km", dark),
      ],
    );
  }

  Widget _metric(String label, String value, bool dark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: dark ? Colors.white : Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: dark ? Colors.white70 : Colors.black87),
        ),
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
          Text(
            "Air Quality Index",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: dark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.orange,
                child: Text(
                  "$aqi",
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                ),
              ),
              const SizedBox(width: 15),
              Text(
                "Moderate air quality today.",
                style: TextStyle(color: dark ? Colors.white70 : Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickAccessGrid(bool dark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxDecoration(dark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quick Access",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: dark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _quickAccessButton("Radar", Icons.radar, Colors.blue, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          RadarScreen(lat: currentLat, lon: currentLon)),
                );
              }),
              _quickAccessButton("Anomalies", Icons.warning, Colors.orange, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          AnomaliesScreen(lat: currentLat, lon: currentLon)),
                );
              }),
              _quickAccessButton(
                  "Forecast", Icons.calendar_view_day, Colors.green, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ForecastDashboard(
                      lat: currentLat,
                      lon: currentLon,
                      locationName: city,
                      selectedDay: DateTime.now(),
                      token: "",
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickAccessButton(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration(bool dark) => BoxDecoration(
        color: dark ? Colors.white10 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      );

  BoxDecoration _smallBox(bool dark) => BoxDecoration(
        color: dark ? Colors.white12 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      );
}
