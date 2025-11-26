{"id":"59211","variant":"standard","title":"commute_dashboard.dart (updated)"}
import 'dart:math';
import 'package:flutter/material.dart';

import 'commute_weather_mini.dart';
import 'commute_quick_actions.dart';
import 'commute_safety_card.dart';
import 'commute_alerts.dart';
import 'commute_route_preview.dart';

class CommuteDashboard extends StatefulWidget {
  const CommuteDashboard({super.key});

  @override
  State<CommuteDashboard> createState() => _CommuteDashboardState();
}

class _CommuteDashboardState extends State<CommuteDashboard> {
  // BASIC INFO
  String currentPlace = "Kochi, Kerala";
  double temp = 30;
  int aqi = 95;
  int commuteSafety = 88;

  List<Map<String, String>> commuteAlerts = [];

  @override
  void initState() {
    super.initState();
    _generateMockAlerts();
  }

  void _generateMockAlerts() {
    commuteAlerts = [
      {
        "title": "Traffic congestion",
        "desc": "Heavy traffic near Vyttila Junction. Expect ~15 min delay."
      },
      {
        "title": "Rain patch expected",
        "desc": "Light rain expected between 5 PM – 6 PM."
      },
    ];
  }

  void _refreshData() {
    setState(() {
      temp = 26 + Random().nextInt(6);
      aqi = 60 + Random().nextInt(60);
      commuteSafety = 70 + Random().nextInt(25);
      _generateMockAlerts();
    });
  }

  void _openQuickActions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: CommuteQuickActions(),
      ),
    );
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
        child: const Icon(
          Icons.flash_on_rounded,
          size: 28,
        ),
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
            const CommuteRoutePreview(),

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
