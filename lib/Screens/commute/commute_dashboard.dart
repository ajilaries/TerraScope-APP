import 'dart:math';
import 'package:flutter/material.dart';
import '../../Services/location_service.dart';
import 'commute_weather_mini.dart';
import 'commute_quick_actions.dart';
import 'commute_alerts.dart';
import 'commute_route_preview.dart';
import 'commute_saftey_card.dart';
import '../../Services/weather_services.dart';
import '../../Services/commute_service.dart';

class CommuteDashboard extends StatefulWidget {
  const CommuteDashboard({super.key});

  @override
  State<CommuteDashboard> createState() => _CommuteDashboardState();
}

class _CommuteDashboardState extends State<CommuteDashboard> {
  String currentPlace = "Loading...";
  double temp = 0.0;
  int aqi = 0;
  int commuteSafety = 0;
  double? _lastLat;
  double? _lastLon;
  double? _destinationLat;
  double? _destinationLon;
  String? _destinationAddress;

// ✔️ Updated list type
  List<CommuteAlert> commuteAlerts = [];

  @override
  void initState() {
    super.initState();
    _initCommute();
  }

  Future<void> _initCommute() async {
    // Use real data from existing services
    final pos = await LocationService.getCurrentPosition();
    if (pos != null) {
      _lastLat = pos.latitude;
      _lastLon = pos.longitude;
      final place = await LocationService.getAddressFromCoordinates(
          pos.latitude, pos.longitude);
      final weather =
          await WeatherService.getWeatherData(pos.latitude, pos.longitude);
      final aqiData =
          await WeatherService.getAQIData(pos.latitude, pos.longitude);
      final safetyScore = await CommuteService.calculateSafetyScore(
          pos.latitude, pos.longitude);
      final realAlerts =
          await CommuteService.getRealAlerts(pos.latitude, pos.longitude);

      setState(() {
        currentPlace = place ?? "Current Location";
        temp = weather != null
            ? (weather['main']['temp'] as num).toDouble()
            : 25.0;
        aqi = aqiData != null ? (aqiData['aqi'] as num).toInt() : 50;
        commuteSafety = safetyScore;
        commuteAlerts = realAlerts
            .map((alert) => CommuteAlert(
                  title: alert['title'],
                  description: alert['description'],
                  time: alert['time'],
                  type: _getAlertTypeFromString(alert['type']),
                ))
            .toList();
      });
    } else {
      setState(() {
        currentPlace = "Location unavailable";
        temp = 25.0;
        aqi = 50;
        commuteSafety = 50;
        commuteAlerts = [];
      });
    }
  }

// ✔️ Updated to CommuteAlert model
  void _generateMockAlerts() {
    commuteAlerts = [
      CommuteAlert(
        title: "Traffic congestion",
        description:
            "Heavy traffic near Vyttila Junction. Expect ~15 min delay.",
        time: "Just now",
        type: AlertType.traffic,
      ),
      CommuteAlert(
        title: "Rain patch expected",
        description: "Light rain expected between 5 PM – 6 PM.",
        time: "5 mins ago",
        type: AlertType.weather,
      ),
    ];
  }

  void _refreshData() async {
    // Use real data for refresh
    final pos = await LocationService.getCurrentPosition();
    if (pos != null) {
      _lastLat = pos.latitude;
      _lastLon = pos.longitude;
      final weather =
          await WeatherService.getWeatherData(pos.latitude, pos.longitude);
      final aqiData =
          await WeatherService.getAQIData(pos.latitude, pos.longitude);
      final safetyScore = await CommuteService.calculateSafetyScore(
          pos.latitude, pos.longitude);
      final realAlerts =
          await CommuteService.getRealAlerts(pos.latitude, pos.longitude);

      setState(() {
        temp = weather != null
            ? (weather['main']['temp'] as num).toDouble()
            : 25.0;
        aqi = aqiData != null ? (aqiData['aqi'] as num).toInt() : 50;
        commuteSafety = safetyScore;
        commuteAlerts = realAlerts
            .map((alert) => CommuteAlert(
                  title: alert['title'],
                  description: alert['description'],
                  time: alert['time'],
                  type: _getAlertTypeFromString(alert['type']),
                ))
            .toList();
      });
    }
  }

  AlertType _getAlertTypeFromString(String type) {
    switch (type) {
      case 'weather':
        return AlertType.weather;
      case 'traffic':
        return AlertType.traffic;
      case 'safety':
        return AlertType.safety;
      default:
        return AlertType.weather;
    }
  }

  void _openQuickActions() {
    CommuteQuickActions.show(
        context, _destinationLat, _destinationLon, _destinationAddress);
  }

  void _onDestinationChanged(double? lat, double? lon, String? address) {
    setState(() {
      _destinationLat = lat;
      _destinationLon = lon;
      _destinationAddress = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Commute Mode"),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openQuickActions,
        backgroundColor: Colors.indigo.shade700,
        child: const Icon(Icons.flash_on_rounded, size: 28),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommuteWeatherMini(
              place: currentPlace,
              temp: temp,
              aqi: aqi,
            ),
            const SizedBox(height: 12),
            CommuteRoutePlanner(onDestinationChanged: _onDestinationChanged),
            const SizedBox(height: 12),
            CommuteSafetyCard(score: commuteSafety),
            const SizedBox(height: 14),
            CommuteAlerts(alerts: commuteAlerts),
          ],
        ),
      ),
    );
  }
}
