import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:terra_scope_apk/Screens/traveler/traveler_quick_actions.dart';

class TravelerDashboard extends StatefulWidget {
  const TravelerDashboard({super.key});

  @override
  State<TravelerDashboard> createState() => _TravelerDashboardState();
}

class _TravelerDashboardState extends State<TravelerDashboard> {
  String currentPlace = "Kochi, Kerala";
  double currentTemp = 28.0;
  double currentHumidity = 72;
  double currentWind = 10.5;
  int currentAQI = 85;

  final TextEditingController _fromCtrl =
      TextEditingController(text: "Current Location");
  final TextEditingController _toCtrl =
      TextEditingController(text: "Alleppey, Kerala");
  bool _planning = false;

  List<Map<String, String>> hourlyRoute = [];
  List<Map<String, String>> routeAlerts = [];

  int travelSafetyScore = 92;
  bool shareLocation = false;

  @override
  void initState() {
    super.initState();
    _setMockHourly();
  }

  void _setMockHourly() {
    hourlyRoute = List.generate(8, (i) {
      final hour = "${6 + i}:00";
      final rains =
          (i % 3 == 0) ? "Heavy rain" : (i % 2 == 0 ? "Cloudy" : "Clear");
      final temp = "${26 + Random().nextInt(6)}°C";
      return {"hour": hour, "weather": rains, "temp": temp};
    });

    routeAlerts = [
      {
        "title": "Heavy rain forecast on NH 66",
        "desc":
            "Moderate to heavy rainfall expected between 2 PM - 5 PM on your route."
      },
      {
        "title": "Low visibility patch",
        "desc": "Fog reported near km 34-40. Drive slow and use fog lights."
      }
    ];
  }

  Future<void> _planRoute() async {
    setState(() {
      _planning = true;
      hourlyRoute = [];
      routeAlerts = [];
    });

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _setMockHourly();
      travelSafetyScore =
          routeAlerts.isNotEmpty ? max(60, travelSafetyScore - 12) : 95;
      _planning = false;
    });
  }

  Widget _card(Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: child,
    );
  }

  Color _safetyColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  void _showAlertsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        expand: false,
        builder: (context, scrollCtrl) {
          return Container(
            padding: const EdgeInsets.all(12),
            child: ListView.separated(
              controller: scrollCtrl,
              itemCount: routeAlerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final a = routeAlerts[idx];
                return ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red),
                  title: Text(a["title"] ?? ""),
                  subtitle: Text(a["desc"] ?? ""),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _onSOS() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("SOS triggered — demo (backend not added)")),
    );
  }

  void _toggleShare() {
    setState(() => shareLocation = !shareLocation);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(shareLocation ? "Share enabled" : "Share disabled")),
    );
  }

  // ---------- NEW: TRAVEL TOOLS QUICK PANEL ----------
  void _showTravelTools() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(26))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.45,
        initialChildSize: 0.55,
        maxChildSize: 0.90,
        builder: (context, scrollCtrl) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: ListView(
              controller: scrollCtrl,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const Text(
                  "Travel Tools",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _toolTile(Icons.route, "Route Weather"),
                    _toolTile(Icons.backpack, "Packing Assist"),
                    _toolTile(Icons.place, "Nearby Spots"),
                    _toolTile(Icons.map, "Map Mode"),
                    _toolTile(Icons.health_and_safety, "Safety Info"),
                    _toolTile(Icons.emergency_share, "Emergency"),
                    _toolTile(Icons.settings, "Preferences"),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _toolTile(IconData icon, String text) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: Colors.indigo.shade700),
          const SizedBox(height: 8),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    );
  }
  // ---------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final safetyColor = _safetyColor(travelSafetyScore);

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
                currentTemp =
                    (25 + Random().nextInt(8)).toDouble();
                currentAQI = 50 + Random().nextInt(80);
                _setMockHourly();
                travelSafetyScore =
                    80 + Random().nextInt(20);
              });
            },
          )
        ],
      ),

      // 🔥🔥 NEW: Floating Button for Travel Tools
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo.shade700,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        onPressed: _showTravelTools,
        child: const Icon(Icons.grid_view_rounded, size: 28),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _card(Row(
              children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(currentPlace,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(
                            "Feels like ${currentTemp.toStringAsFixed(0)}°C • Humidity $currentHumidity%"),
                        const SizedBox(height: 6),
                        Text(
                            "Wind ${currentWind.toStringAsFixed(1)} km/h • AQI $currentAQI"),
                      ]),
                ),
                Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          Colors.indigo.shade50,
                      child: Text(
                        "${currentTemp.toStringAsFixed(0)}°",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _showAlertsSheet,
                      icon: const Icon(Icons.notifications_active),
                      label: const Text("Alerts"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red.shade400),
                    ),
                  ],
                )
              ],
            )),

            _card(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Plan Route",
                    style: TextStyle(
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _fromCtrl,
                  decoration: const InputDecoration(
                      labelText: "From",
                      prefixIcon: Icon(Icons.my_location)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _toCtrl,
                  decoration: const InputDecoration(
                      labelText: "To",
                      prefixIcon: Icon(Icons.place)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            _planning ? null : _planRoute,
                        icon: _planning
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ))
                            : const Icon(Icons.alt_route),
                        label: Text(_planning
                            ? "Planning..."
                            : "Plan Route"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.indigo.shade700),
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
            )),

            _card(Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text("Travel Safety",
                            style: TextStyle(
                                fontWeight:
                                    FontWeight.w700)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: safetyColor
                                    .withOpacity(0.12),
                              ),
                              child: Center(
                                child: Text(
                                  "$travelSafetyScore",
                                  style: TextStyle(
                                      color: safetyColor,
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                travelSafetyScore >= 80
                                    ? "Safe to travel"
                                    : (travelSafetyScore >= 50
                                        ? "Take caution"
                                        : "Avoid travel"),
                                style: TextStyle(
                                    fontSize: 16,
                                    color: safetyColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: travelSafetyScore / 100,
                          color: safetyColor,
                          backgroundColor:
                              Colors.grey.shade300,
                        )
                      ]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 110,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius:
                            BorderRadius.circular(10)),
                    child: const Center(
                        child: Text(
                      "Map preview\n(plug Google Maps here)",
                      textAlign: TextAlign.center,
                    )),
                  ),
                ),
              ],
            )),

            _card(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Hourly along route",
                    style: TextStyle(
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: hourlyRoute.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final h = hourlyRoute[idx];
                      return Container(
                        width: 120,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius:
                                BorderRadius.circular(10)),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(h["hour"] ?? ""),
                            const SizedBox(height: 6),
                            Text(h["weather"] ?? "",
                                style: const TextStyle(
                                    fontSize: 12)),
                            const SizedBox(height: 6),
                            Text(h["temp"] ?? "",
                                style: const TextStyle(
                                    fontWeight:
                                        FontWeight.bold)),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            )),

            _card(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                        child: Text("Route Alerts",
                            style: TextStyle(
                                fontWeight:
                                    FontWeight.w700))),
                    TextButton(
                      onPressed: _showAlertsSheet,
                      child: const Text("View all"),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                ...routeAlerts.map((a) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.info_outline,
                          color: Colors.orange),
                      title: Text(a["title"] ?? ""),
                      subtitle: Text(a["desc"] ?? ""),
                    )),
                if (routeAlerts.isEmpty)
                  const Text("No alerts on route"),
              ],
            )),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _onSOS,
                    icon: const Icon(Icons.report),
                    label: const Text("SOS"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.red.shade700),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _toggleShare,
                    icon: Icon(shareLocation
                        ? Icons.share
                        : Icons.share_outlined),
                    label: Text(shareLocation
                        ? "Sharing"
                        : "Share Location"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
