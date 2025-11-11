import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';
import '../Services/location_service.dart';
import '../Services/weather_services.dart';
import 'package:geolocator/geolocator.dart';

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

  StreamSubscription<Position>? positionStream;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _fetchWeatherData(initial: true);
    _startAutoRefresh();
    _listenToLiveLocation();
    LocationService().updateDeviceLocationToBackend();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    positionStream?.cancel();
    super.dispose();
  }

  // ✅ Update date & time
  void _updateDateTime() {
    final now = DateTime.now();
    day = DateFormat('EEE, MMM d').format(now);
    time = DateFormat('hh:mm a').format(now);
  }

  // ✅ Auto refresh every 5 min
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _fetchWeatherData(),
    );
  }

  // ✅ Listen to real-time GPS updates
  void _listenToLiveLocation() {
    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10, // update only if moved 10 meters
          ),
        ).listen((Position pos) async {
          print("📍 Live GPS: ${pos.latitude}, ${pos.longitude}");

          await _fetchWeatherData(lat: pos.latitude, lon: pos.longitude);
        });
  }

  // ✅ Fetch weather (initial or GPS-triggered)
Future<void> _fetchWeatherData({
  bool initial = false,
  double? lat,
  double? lon,
}) async {
  setState(() => isRefreshing = true);

  const String token = "YOUR_DEVICE_TOKEN"; // <-- Replace with real device/user token

  try {
    // ✅ If GPS not passed from stream, get current location
    if (lat == null || lon == null) {
      final loc = await LocationService().getCurrentLocation();
      lat = loc["latitude"];
      lon = loc["longitude"];
    }

    final locInfo = await LocationService().getCurrentLocation();
    locationName = "${locInfo["city"]}, ${locInfo["country"]}";
    latitude = lat!.toStringAsFixed(4);
    longitude = lon!.toStringAsFixed(4);

    // ✅ Fetch weather from backend (pass token!)
    final latest = await WeatherService().getWeatherData(
      token: token,
      lat: lat,
      lon: lon,
    );

    final temp = latest["temperature"] ?? 0;
    final rainfall = latest["rainfall"] ?? 0;
    final condition = latest["condition"] ?? (rainfall > 0 ? "Rain" : "Clear");

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
      temperature = "---°C";
      weatherCondition = "Unknown";
      weatherIcon = WeatherIcons.na;
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
            onPressed: isRefreshing ? null : () => _fetchWeatherData(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset(bgImage, fit: BoxFit.cover)),
          Container(color: Colors.black.withOpacity(0.3)),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
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
                    children: [
                      Icon(weatherIcon, size: 80, color: Colors.white),
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
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
