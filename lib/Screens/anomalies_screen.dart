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
      anomalies = await WeatherService.getAnomalies(widget.lat, widget.lon);
      setState(() => isLoading = false);
    } catch (e) {
      debugPrint("Error fetching anomalies: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Anomalies & Alerts")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : anomalies.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: anomalies.length,
                  itemBuilder: (context, index) {
                    final a = anomalies[index];
                    return Card(
                      color: Colors.redAccent.withValues(alpha: 0.2),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.green.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            "No Weather Anomalies",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Great news! No severe weather alerts\nor anomalies detected in your area.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchAnomalies,
            icon: const Icon(Icons.refresh),
            label: const Text("Check Again"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
