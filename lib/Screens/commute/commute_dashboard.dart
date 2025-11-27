import 'dart:math';
import 'package:flutter/material.dart';

import 'commute_weather_mini.dart';
import 'commute_quick_actions.dart';
import 'commute_alerts.dart';
import 'commute_route_preview.dart';
import 'commute_saftey_card.dart';

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

// ✔️ Updated list type
List<CommuteAlert> commuteAlerts = [];

@override
void initState() {
super.initState();
_generateMockAlerts();
}

// ✔️ Updated to CommuteAlert model
void _generateMockAlerts() {
commuteAlerts = [
CommuteAlert(
title: "Traffic congestion",
description: "Heavy traffic near Vyttila Junction. Expect ~15 min delay.",
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
setState(() {
temp = (26 + Random().nextInt(6)).toDouble();
aqi = 60 + Random().nextInt(60);
commuteSafety = 70 + Random().nextInt(25);
_generateMockAlerts();
});
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
