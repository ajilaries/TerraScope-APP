import 'package:flutter/material.dart';
import '../../Services/location_service.dart';
import 'commute_weather_mini.dart';
import 'commute_quick_actions.dart';
import 'commute_alerts.dart';
import 'commute_route_preview.dart';
import 'commute_saftey_card.dart';
import '../../Services/weather_services.dart';
import '../../Services/commute_service.dart';

class NearestTransitCard extends StatefulWidget {
  const NearestTransitCard({super.key});

  @override
  State<NearestTransitCard> createState() => _NearestTransitCardState();
}

class _NearestTransitCardState extends State<NearestTransitCard> {
  Map<String, dynamic>? nearestMetro;
  Map<String, dynamic>? nearestBus;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNearestTransit();
  }

  Future<void> _loadNearestTransit() async {
    final pos = await LocationService.getCurrentPosition();
    if (pos != null) {
      final metro =
          await CommuteService.getNearestMetro(pos.latitude, pos.longitude);
      final bus =
          await CommuteService.getNearestBusStop(pos.latitude, pos.longitude);
      setState(() {
        nearestMetro = metro;
        nearestBus = bus;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_transit, color: Colors.indigo.shade700),
                const SizedBox(width: 8),
                const Text(
                  "Nearest Transit",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: _transitItem(
                      icon: Icons.subway,
                      title: "Metro",
                      name: nearestMetro?['name'] ?? "Not found",
                      color: Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _transitItem(
                      icon: Icons.directions_bus,
                      title: "Bus",
                      name: nearestBus?['name'] ?? "Not found",
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _transitItem({
    required IconData icon,
    required String title,
    required String name,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            name.length > 15 ? "${name.substring(0, 15)}..." : name,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

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

  void _refreshData() async {
    // Use real data for refresh
    final pos = await LocationService.getCurrentPosition();
    if (pos != null) {
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
            const NearestTransitCard(),
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
