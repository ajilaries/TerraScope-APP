import 'dart:math';
import 'package:flutter/material.dart';

import 'commute_weather_mini.dart';
import 'commute_quick_actions.dart';
import 'commute_alerts.dart';
import 'commute_route_preview.dart';
import 'commute_saftey_card.dart';
import '../../Services/commute_service.dart';

class CommuteDashboard extends StatefulWidget {
  const CommuteDashboard({super.key});

  @override
  State<CommuteDashboard> createState() => _CommuteDashboardState();
}

class _CommuteDashboardState extends State<CommuteDashboard> {
  String currentPlace = "Kochi, Kerala";
  double temp = 30;
  int aqi = 95;
  int commuteSafety = 88;
  double? _lastLat;
  double? _lastLon;

// ✔️ Updated list type
  List<CommuteAlert> commuteAlerts = [];

  @override
  void initState() {
    super.initState();
    _generateMockAlerts();
    _initCommute();
  }

  Future<void> _initCommute() async {
    try {
      final pos = await CommuteService.getCurrentPosition();
      if (pos != null) {
        _lastLat = pos.latitude;
        _lastLon = pos.longitude;
      }
      final place = await CommuteService.reverseGeocode(_lastLat!, _lastLon!);

      final weather = await CommuteService.fetchWeather(_lastLat!, _lastLon!);

      setState(() {
        currentPlace = place;
        if (weather.containsKey('temp'))
          temp = (weather['temp'] as double?) ?? temp;
        if (weather.containsKey('aqi')) aqi = (weather['aqi'] as int?) ?? aqi;
      });
    } catch (_) {
      // keep mock values on failure
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

  void _refreshData() {
    // Try to refresh real data if possible, else fallback to mock
    if (_lastLat != null && _lastLon != null) {
      CommuteService.fetchWeather(_lastLat!, _lastLon!).then((weather) {
        setState(() {
          if (weather.containsKey('temp'))
            temp = (weather['temp'] as double?) ?? temp;
          if (weather.containsKey('aqi')) aqi = (weather['aqi'] as int?) ?? aqi;
          commuteSafety = 70 + Random().nextInt(25);
          _generateMockAlerts();
        });
      }).catchError((_) {
        // fallback
        setState(() {
          temp = (26 + Random().nextInt(6)).toDouble();
          aqi = 60 + Random().nextInt(60);
          commuteSafety = 70 + Random().nextInt(25);
          _generateMockAlerts();
        });
      });
    } else {
      setState(() {
        temp = (26 + Random().nextInt(6)).toDouble();
        aqi = 60 + Random().nextInt(60);
        commuteSafety = 70 + Random().nextInt(25);
        _generateMockAlerts();
      });
    }
  }

  void _openQuickActions() {
    CommuteQuickActions.show(context);
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
            const CommuteRoutePlanner(),
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
