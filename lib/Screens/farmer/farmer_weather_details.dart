import 'package:flutter/material.dart';

class FarmerWeatherDetails extends StatelessWidget {
  const FarmerWeatherDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Temperature Card
            _weatherCard(
              title: "Temperature",
              icon: Icons.thermostat,
              value: "28°C",
              subtitle: "Feels like 30°C",
              color: Colors.orange,
            ),

            const SizedBox(height: 16),

            // Rainfall Probability
            _weatherCard(
              title: "Rainfall Chances",
              icon: Icons.cloudy_snowing,
              value: "52%",
              subtitle: "Possible light rain",
              color: Colors.blue,
            ),

            const SizedBox(height: 16),

            // Humidity
            _weatherCard(
              title: "Humidity",
              icon: Icons.water_drop,
              value: "73%",
              subtitle: "Moderate humidity",
              color: Colors.indigo,
            ),

            const SizedBox(height: 16),

            // Wind
            _weatherCard(
              title: "Wind",
              icon: Icons.air,
              value: "12 km/h",
              subtitle: "Mild breeze",
              color: Colors.green,
            ),

            const SizedBox(height: 16),

            // UV Index
            _weatherCard(
              title: "UV Index",
              icon: Icons.wb_sunny,
              value: "6",
              subtitle: "High — wear protection",
              color: Colors.yellow.shade700,
            ),

            const SizedBox(height: 24),

            // Recommended Actions Section
            Text(
              "Today's Suggestions",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _suggestionTile("Good time to irrigate crops", Icons.check_circle),
            _suggestionTile("Avoid direct sunlight during noon", Icons.warning),
            _suggestionTile("Rain expected in evening — protect harvested crops",
                Icons.umbrella),
          ],
        ),
      ),
    );
  }

  // Weather Card UI Component
  Widget _weatherCard({
    required String title,
    required IconData icon,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Suggestion Tile
  Widget _suggestionTile(String text, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        ],
      ),
    );
  }
}
