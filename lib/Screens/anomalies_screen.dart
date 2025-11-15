import 'package:flutter/material.dart';
import '../Services/weather_services.dart';

class AnomaliesScreen extends StatefulWidget {
  final double lat;
  final double lon;

  const AnomaliesScreen({super.key, required this.lat, required this.lon});

  @override
  State<AnomaliesScreen> createState() => _AnomaliesScreenState();
}

class _AnomaliesScreenState extends State<AnomaliesScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> anomalies = [];

  @override
  void initState() {
    super.initState();
    _fetchAnomalies();
  }

  Future<void> _fetchAnomalies() async {
    setState(() => isLoading = true);
    try {
      anomalies = await WeatherService().getAnomalies(widget.lat, widget.lon);
      setState(() => isLoading = false);
    } catch (e) {
      print("Error fetching anomalies: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Anomalies & Alerts")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: anomalies.length,
              itemBuilder: (context, index) {
                final a = anomalies[index];
                return Card(
                  color: Colors.redAccent.withOpacity(0.2),
                  child: ListTile(
                    leading: Icon(Icons.warning, color: Colors.red),
                    title: Text(a['type']),
                    subtitle: Text("Forecast: ${a['forecast']}"),
                    trailing: Text(a['time']),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchAnomalies,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
