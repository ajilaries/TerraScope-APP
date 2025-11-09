import 'package:flutter/material.dart';

class AnomalyScreen extends StatelessWidget {
  const AnomalyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),

      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        title: const Text(
          "Anomaly Alerts",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ✅ Current Status Card
            _currentStatusCard(),

            const SizedBox(height: 25),

            const Text(
              "Past Alerts",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            // ✅ Fake temporary past alerts list
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _alertTile(
                    title: "Heavy Rainfall Detected",
                    icon: Icons.water_drop,
                    time: "Today • 10:42 AM",
                    color1: Colors.blueAccent,
                    color2: Colors.lightBlueAccent,
                  ),
                  _alertTile(
                    title: "Heatwave Warning",
                    icon: Icons.local_fire_department,
                    time: "Yesterday • 4:15 PM",
                    color1: Colors.orangeAccent,
                    color2: Colors.deepOrangeAccent,
                  ),
                  _alertTile(
                    title: "Storm Surge Risk",
                    icon: Icons.thunderstorm,
                    time: "Nov 8 • 9:00 AM",
                    color1: Colors.purpleAccent,
                    color2: Colors.deepPurpleAccent,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ✅ Current anomaly status card
  Widget _currentStatusCard() {
    bool anomalyDetected = false; // TEMP: later we replace with backend data

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: anomalyDetected
              ? [Colors.redAccent, Colors.deepOrange]
              : [Colors.greenAccent, Colors.teal],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            anomalyDetected
                ? Icons.warning_amber_rounded
                : Icons.verified_rounded,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              anomalyDetected
                  ? "Anomaly Detected!\nHigh rainfall expected"
                  : "All Clear ✅\nNo anomalies in your area",
              style: const TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Past alert tile
  Widget _alertTile({
    required String title,
    required IconData icon,
    required String time,
    required Color color1,
    required Color color2,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            color1.withOpacity(0.3),
            color2.withOpacity(0.3),
          ],
        ),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 36, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          )
        ],
      ),
    );
  }
}
