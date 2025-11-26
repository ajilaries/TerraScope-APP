import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'travel_map_preview.dart';

import 'traveler_alerts.dart';
import 'traveler_hourly_route.dart';
import 'traveler_saftey_card.dart';
import 'traveler_quick_actions.dart';
import 'traveler_sos_share.dart';

class TravelerDashboard extends StatefulWidget {
  const TravelerDashboard({super.key});

  @override
  State<TravelerDashboard> createState() => _TravelerDashboardState();
}

class _TravelerDashboardState extends State<TravelerDashboard> {
  // ------------------------
  // STATE VARIABLES
  // ------------------------
  String currentPlace = "Kochi, Kerala";
  double currentTemp = 28.0;
  double currentHumidity = 72;
  double currentWind = 10.5;
  int currentAQI = 85;

  final TextEditingController _fromCtrl = TextEditingController(text: "Current Location");
  final TextEditingController _toCtrl = TextEditingController(text: "Alleppey, Kerala");

  bool _planning = false;
  bool shareLocation = false;

  int travelSafetyScore = 92;

  List<Map<String, String>> hourlyRoute = [];
  List<Map<String, String>> routeAlerts = [];

  // ------------------------
  // LIFECYCLE
  // ------------------------
  @override
  void initState() {
    super.initState();
    _generateMockData();
  }

  // ------------------------
  // MOCK DATA GENERATION
  // ------------------------
  void _generateMockData() {
    hourlyRoute = List.generate(8, (i) {
      final hour = "${6 + i}:00";
      final weather = (i % 3 == 0) ? "Heavy rain" : (i % 2 == 0 ? "Cloudy" : "Clear");
      final temp = "${26 + Random().nextInt(6)}°C";
      return {"hour": hour, "weather": weather, "temp": temp};
    });

    routeAlerts = [
      {
        "title": "Heavy rain forecast on NH 66",
        "desc": "Moderate to heavy rainfall expected between 2 PM - 5 PM on your route."
      },
      {
        "title": "Low visibility patch",
        "desc": "Fog reported near km 34-40. Drive slow and use fog lights."
      }
    ];
  }

  // ------------------------
  // PLAN ROUTE FUNCTION
  // ------------------------
  Future<void> _planRoute() async {
    setState(() {
      _planning = true;
      hourlyRoute.clear();
      routeAlerts.clear();
    });

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _generateMockData();
      travelSafetyScore = routeAlerts.isNotEmpty ? max(60, travelSafetyScore - 12) : 95;
      _planning = false;
    });
  }

  // ------------------------
  // SOS / SHARE HANDLERS
  // ------------------------
  void _onSOS() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("SOS triggered — demo (backend not added)")),
    );
  }

  void _toggleShare() {
    setState(() => shareLocation = !shareLocation);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(shareLocation ? "Share enabled" : "Share disabled")),
    );
  }

  // ------------------------
  // TRAVEL TOOLS PANEL
  // ------------------------
  void _showTravelTools() => TravelerQuickActions.show(context);

  // ------------------------
  // WEATHER CARD WIDGET
  // ------------------------
  Widget _weatherCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(currentPlace,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text("Feels like ${currentTemp.toStringAsFixed(0)}°C • Humidity $currentHumidity%"),
                    const SizedBox(height: 6),
                    Text("Wind ${currentWind.toStringAsFixed(1)} km/h • AQI $currentAQI"),
                  ]),
            ),
            Column(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.indigo.shade50,
                  child: Text("${currentTemp.toStringAsFixed(0)}°",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => TravelerAlerts.show(context, routeAlerts),
                  icon: const Icon(Icons.notifications_active),
                  label: const Text("Alerts"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ------------------------
  // PLAN ROUTE CARD WIDGET
  // ------------------------
  Widget _planRouteCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Plan Route", style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _fromCtrl,
              decoration: const InputDecoration(labelText: "From", prefixIcon: Icon(Icons.my_location)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _toCtrl,
              decoration: const InputDecoration(labelText: "To", prefixIcon: Icon(Icons.place)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _planning ? null : _planRoute,
                    icon: _planning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.alt_route),
                    label: Text(_planning ? "Planning..." : "Plan Route"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade700),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final t = _fromCtrl.text;
                    _fromCtrl.text = _toCtrl.text;
                    _toCtrl.text = t;
                  },
                  child: const Icon(Icons.swap_horiz),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------
  // BUILD
  // ------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Traveler Mode"),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                currentTemp = (25 + Random().nextInt(8)).toDouble();
                currentAQI = 50 + Random().nextInt(80);
                _generateMockData();
                travelSafetyScore = 80 + Random().nextInt(20);
              });
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: _showTravelTools,
        child: const Icon(Icons.grid_view_rounded, size: 28),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _weatherCard(),
            _planRouteCard(),
            TravelerSafetyCard(score: travelSafetyScore),
            TravelerHourlyRoute(hourlyRoute: hourlyRoute),
            TravelerAlerts(routeAlerts: routeAlerts, onViewAll: () {
              TravelerAlerts.show(context, routeAlerts);
            }),
            const SizedBox(height: 10),
            TravelerSOSShare(
              shareLocation: shareLocation,
              onSOS: _onSOS,
              onToggleShare: _toggleShare,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
