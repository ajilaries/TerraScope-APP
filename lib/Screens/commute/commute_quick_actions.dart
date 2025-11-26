import 'package:flutter/material.dart';

class CommuteQuickActions {
  static Future<void> show(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Commute Tools",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Metro Timings
              _actionTile(
                icon: Icons.subway,
                title: "Metro Timings",
                subtitle: "Next train & route schedule",
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Metro Timings — demo")),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Bus Status
              _actionTile(
                icon: Icons.directions_bus,
                title: "Bus Status",
                subtitle: "Live bus arrival & delays",
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Bus Status — demo")),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Cab Fare Estimate
              _actionTile(
                icon: Icons.local_taxi,
                title: "Cab Fare Estimate",
                subtitle: "Auto/Taxi/OLA/UBER approx fare",
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Cab Fare — demo")),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Traffic Report
              _actionTile(
                icon: Icons.traffic,
                title: "Traffic Density",
                subtitle: "Slow / Moderate / Heavy traffic",
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Traffic Report — demo")),
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  static Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.indigo.shade50,
            child: Icon(icon, color: Colors.indigo.shade700, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
