import 'package:flutter/material.dart';

class FarmerAlertsScreen extends StatelessWidget {
  const FarmerAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
        title: const Text(
          "Weather Alerts",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // TODAY ALERTS
            const Text(
              "Today's Alerts",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),

            _todayAlertCard(
              icon: Icons.water_drop,
              title: "Heavy Rainfall Expected",
              desc: "Rainfall levels may exceed normal by 70%.",
              color: Colors.blue.shade50,
              iconColor: Colors.blue,
              time: "2h ago",
            ),

            const SizedBox(height: 12),

            _todayAlertCard(
              icon: Icons.wind_power,
              title: "Strong Wind Warning",
              desc: "Wind speeds expected to cross 40 km/h.",
              color: Colors.orange.shade50,
              iconColor: Colors.orange,
              time: "4h ago",
            ),

            const SizedBox(height: 30),

            // PAST ALERTS TIMELINE HEADER
            const Text(
              "Alert History",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),

            // TIMELINE
            _timelineAlert(
              date: "Nov 20",
              title: "Soil Moisture Drop",
              desc: "Soil moisture fell below ideal level.",
              color: Colors.green,
            ),
            _timelineAlert(
              date: "Nov 18",
              title: "Low Pressure Zone",
              desc: "Possible rainfall due to pressure drop.",
              color: Colors.blue,
            ),
            _timelineAlert(
              date: "Nov 16",
              title: "High UV Exposure",
              desc: "UV index reached 8 (Very High).",
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // TODAY'S ALERT CARD
  // ================================================================
  Widget _todayAlertCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
    required Color iconColor,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: iconColor.withOpacity(0.15),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(color: Colors.grey.shade800),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ================================================================
  // TIMELINE ALERT ITEM
  // ================================================================
  Widget _timelineAlert({
    required String date,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TIMELINE DOT + LINE
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 3,
              height: 60,
              color: color.withOpacity(0.4),
            ),
          ],
        ),

        const SizedBox(width: 12),

        // CARD CONTENT
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$date • $title",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

