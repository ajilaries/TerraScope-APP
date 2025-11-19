import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../Services/location_service.dart';
import '../Services/weather_services.dart';
import '../providers/mode_provider.dart';
import '../utils/background_helper.dart';

import '../Screens/forecast_dashboard.dart';
import '../Screens/radar_screen.dart';
import '../Screens/anomalies_screen.dart';
import '../Screens/panic_screen.dart';

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
  String backgroundImage = "lib/assets/images/default.jpg";

  String latitude = "--";
  String longitude = "--";

  String day = "";
  String time = "";
  String lastUpdated = "—";

  bool isRefreshing = false;

  StreamSubscription<Position>? positionStream;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _fetchWeatherData(initial: true);
    _startAutoRefresh();
    _listenToLiveLocation();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    positionStream?.cancel();
    super.dispose();
  }

  // 🔹 Update date and time for UI
  void _updateDateTime() {
    final now = DateTime.now();
    day = DateFormat('EEE, MMM d').format(now);
    time = DateFormat('hh:mm a').format(now);
  }

  // 🔹 Auto-refresh every 5 minutes
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _fetchWeatherData(),
    );
  }

  // 🔹 Listen to GPS changes
  void _listenToLiveLocation() {
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      ),
    ).listen((pos) async {
      await _fetchWeatherData(lat: pos.latitude, lon: pos.longitude);
    });
  }

  // 🔹 Fetch weather data
  Future<void> _fetchWeatherData({
    bool initial = false,
    double? lat,
    double? lon,
  }) async {
    setState(() => isRefreshing = true);

    try {
      if (lat == null || lon == null) {
        final loc = await LocationService().getCurrentLocation();
        lat = loc["latitude"];
        lon = loc["longitude"];
      }

      final locInfo = await LocationService().getCurrentLocation();
      locationName = "${locInfo["city"]}, ${locInfo["country"]}";

      latitude = lat!.toStringAsFixed(4);
      longitude = lon!.toStringAsFixed(4);

      final weather = await WeatherService().getWeatherData(
        token: "dummy_token",
        lat: lat,
        lon: lon,
      );

      final condition = weather["condition"] ?? "Clear";

      setState(() {
        temperature = "${weather["temperature"]?.toStringAsFixed(1)}°C";
        weatherCondition = condition;
        weatherIcon = WeatherService().getWeatherIcon(condition);
        backgroundImage = getBackgroundImage(condition);
        lastUpdated = DateFormat('hh:mm a').format(DateTime.now());
      });
    } catch (e) {
      setState(() {
        weatherCondition = "Unknown";
        temperature = "---°C";
        weatherIcon = WeatherIcons.na;
        backgroundImage = "lib/assets/images/default.jpg";
      });
    } finally {
      setState(() => isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = Provider.of<ModeProvider>(context).mode;

    // 🔹 Mode-based tint overlay
    Color overlayColor;
    if (mode == 'farm') {
      overlayColor = Colors.green.withOpacity(0.25);
    } else if (mode == 'travel') {
      overlayColor = Colors.blue.withOpacity(0.25);
    } else if (mode == 'safety') {
      overlayColor = Colors.red.withOpacity(0.20);
    } else {
      overlayColor = Colors.black.withOpacity(0.25);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,

      // 🔹 Transparent AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "TerraScope",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: isRefreshing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: isRefreshing ? null : () => _fetchWeatherData(),
          )
        ],
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(backgroundImage, fit: BoxFit.cover),
          ),
          Container(color: overlayColor),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: _fetchWeatherData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 40),

                  // 🔹 Location
                  Text(
                    locationName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Lat: $latitude • Lon: $longitude",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 10),

                  // 🔹 Date + Time
                  Text(
                    "$day · $time",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 40),

                  // 🔹 Weather Card
                  Center(
                    child: Column(
                      children: [
                        BoxedIcon(
                          weatherIcon,
                          size: 90,
                          color: Colors.white,
                        ),
                        Text(
                          temperature,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 58,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          weatherCondition.toUpperCase(),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Updated: $lastUpdated",
                          style: const TextStyle(color: Colors.white60),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🔹 Quick Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _quickButton("Forecast", Icons.calendar_today, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ForecastDashboard(
                              lat: double.parse(latitude),
                              lon: double.parse(longitude),
                              selectedDay: DateTime.now(),
                              locationName: locationName,
                            ),
                          ),
                        );
                      }),

                      _quickButton("Radar", Icons.map, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RadarScreen(lat: double.parse(latitude), lon: double.parse(longitude)),
                          ),
                        );
                      }),

                      _quickButton("Alerts", Icons.warning, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AnomaliesScreen(lat: double.parse(latitude), lon: double.parse(longitude)),
                          ),
                        );
                      }),

                      _quickButton("SOS", Icons.sos, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PanicScreen()),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Quick Button widget
  Widget _quickButton(String name, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
