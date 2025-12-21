import 'package:flutter/material.dart';
import '../Services/anomaly_service.dart';
import '../Services/weather_services.dart';
import '../models/weather_model.dart';

class AnomalyScreen extends StatefulWidget {
  final double lat;
  final double lon;

  const AnomalyScreen({
    super.key,
    required this.lat,
    required this.lon,
  });

  @override
  State<AnomalyScreen> createState() => _AnomalyScreenState();
}

class _AnomalyScreenState extends State<AnomalyScreen> {
  final AnomalyService _anomalyService = AnomalyService();
  final WeatherService _weatherService = WeatherService();

  bool _isLoading = true;
  List<Map<String, dynamic>> _alerts = [];
  String _currentSeverity = "clear";

  @override
  void initState() {
    super.initState();
    _loadAnomalies();
  }

  Future<void> _loadAnomalies() async {
    setState(() => _isLoading = true);

    try {
      // 🌦️ Weather fetch (used for fallback)
      final weatherRaw = await _weatherService.getWeatherData(
        token: "public_token",
        lat: widget.lat,
        lon: widget.lon,
      );

      final weather = WeatherData.fromJson(weatherRaw);

      // 🌪️ Backend anomalies
      List<Map<String, dynamic>> anomalies = await _anomalyService.getAnomalies(
        lat: widget.lat,
        lon: widget.lon,
      );

      // 🧠 Fallback detection if backend empty
      if (anomalies.isEmpty) {
        anomalies = _anomalyService.detectFromWeather(weather);
      }

      _currentSeverity = _resolveSeverity(anomalies);

      setState(() => _alerts = anomalies);
    } catch (e) {
      debugPrint("❌ Anomaly load failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _resolveSeverity(List<Map<String, dynamic>> alerts) {
    if (alerts.any((a) => a['type'] == 'Heavy Rain')) return "danger";
    if (alerts.any((a) => a['type'] == 'Heat Alert')) return "warning";
    return "clear";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        title: const Text(
          "Anomaly Alerts",
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnomalies,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _currentStatusCard(),
                  const SizedBox(height: 26),
                  const Text(
                    "Detected Alerts",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _alerts.isEmpty
                        ? _emptyState()
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _alerts.length,
                            itemBuilder: (context, index) {
                              return _alertTile(_alerts[index]);
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  // 🟢🟠🔴 Status card
  Widget _currentStatusCard() {
    Color c1, c2;
    IconData icon;
    String text;

    switch (_currentSeverity) {
      case "danger":
        c1 = Colors.redAccent;
        c2 = Colors.deepOrange;
        icon = Icons.warning_rounded;
        text = "Severe Anomaly Detected\nImmediate action required";
        break;

      case "warning":
        c1 = Colors.orangeAccent;
        c2 = Colors.amber;
        icon = Icons.report_problem_rounded;
        text = "Potential Anomaly Detected\nStay alert";
        break;

      default:
        c1 = Colors.greenAccent;
        c2 = Colors.teal;
        icon = Icons.verified_rounded;
        text = "All Clear ✅\nNo anomalies detected";
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [c1, c2]),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(icon, size: 48, color: Colors.white),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 📜 Alert tile
  Widget _alertTile(Map<String, dynamic> alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white10,
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alert['type'] ?? "Anomaly",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            alert['message'] ?? "",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Text(
        "No anomalies detected 🎉",
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 15,
        ),
      ),
    );
  }
}
