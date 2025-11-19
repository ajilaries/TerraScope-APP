import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Screens/home_screen2.dart';
import '../Screens/forecast_dashboard.dart';
import '../Screens/radar_screen.dart';
import '../Screens/anomalies_screen.dart';
import '../Screens/panic_screen.dart';
import '../providers/mode_provider.dart';
import '../Services/weather_services.dart';
import '../Services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String smallTemp = "---°C";
  String smallCond = "Loading...";
  String smallCity = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadSmallWeatherPreview();
  }

  Future<void> _loadSmallWeatherPreview() async {
    try {
      final loc = await LocationService().getCurrentLocation();
      final weather = await WeatherService().getWeatherData(
        token: "dummy",
        lat: loc["latitude"],
        lon: loc["longitude"],
      );

      setState(() {
        smallCity = loc["city"];
        smallTemp = "${weather["temperature"]?.toStringAsFixed(1)}°C";
        smallCond = weather["condition"];
      });
    } catch (e) {
      setState(() {
        smallTemp = "---°C";
        smallCond = "Unable to fetch";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = Provider.of<ModeProvider>(context).mode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Terrascope Pro"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          )
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // 🔹 Small Weather Row
          Card(
            child: ListTile(
              leading: const Icon(Icons.wb_sunny_outlined),
              title: Text("$smallCity • $smallTemp"),
              subtitle: Text(smallCond),
            ),
          ),

          const SizedBox(height: 20),

          // 🔹 Mode Buttons
          _bigButton("Real-Time Weather", Icons.cloud, () {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => const HomeScreen2(),
            ));
          }),

          _bigButton("Forecast", Icons.calendar_today, () {}),
          _bigButton("Radar & Maps", Icons.satellite_alt, () {}),
          _bigButton("Anomaly Alerts", Icons.warning_amber, () {}),
          _bigButton("Compass & Sensors", Icons.explore, () {}),
          _bigButton("Panic / Safety Mode", Icons.sos, () {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => const PanicScreen(),
            ));
          }),

          if (mode == "admin") 
            _bigButton("Admin Dashboard", Icons.admin_panel_settings, () {}),

          const SizedBox(height: 30),

          // 🔹 Quick Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _smallStat("Temp", smallTemp),
              _smallStat("Humidity", "—"),
              _smallStat("AQI", "—"),
              _smallStat("Rain", "—"),
            ],
          ),
        ],
      ),
    );
  }

  // 🔸 Big Button
  Widget _bigButton(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }

  // 🔸 Small Stat Box
  Widget _smallStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }
}
