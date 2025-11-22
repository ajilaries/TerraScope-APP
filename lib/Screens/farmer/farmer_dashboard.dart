import 'package:flutter/material.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Farmer Mode",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // WEATHER HEADER CARD
            _weatherHeader(),

            const SizedBox(height: 20),

            // RECOMMENDATION SECTION
            _recommendationSection(),

            const SizedBox(height: 20),

            // WEEKLY FORECAST
            _forecastSection(),

            const SizedBox(height: 20),

            // SOIL DATA
            _soilSection(),

            const SizedBox(height: 20),

            // ALERTS
            _alertsSection(),
          ],
        ),
      ),
    );
  }

  // =============================
  // WEATHER HEADER
  // =============================
  Widget _weatherHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kottayam, Kerala",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "29°C",
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Partly Cloudy",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniInfo(Icons.water_drop, "Humidity", "78%"),
              _miniInfo(Icons.cloudy_snowing, "Rain Chance", "65%"),
              _miniInfo(Icons.air, "Wind", "12 km/h"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 26, color: Colors.white),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // =============================
  // RECOMMENDATION SECTION
  // =============================
  Widget _recommendationSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Today's Recommendations",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10),
          Text("• Irrigation needed: Moderate"),
          Text("• Pest Alert: Low risk"),
          Text("• Fertilizer suggestion: NPK 10-26-26"),
          Text("• Ideal spraying time: 4 PM to 6 PM"),
        ],
      ),
    );
  }

  // =============================
  // FORECAST SECTION
  // =============================
  Widget _forecastSection() {
    List<Map<String, dynamic>> forecast = [
      {"day": "Mon", "temp": "29°", "rain": "40%"},
      {"day": "Tue", "temp": "31°", "rain": "55%"},
      {"day": "Wed", "temp": "28°", "rain": "80%"},
      {"day": "Thu", "temp": "30°", "rain": "20%"},
      {"day": "Fri", "temp": "32°", "rain": "10%"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Weekly Forecast",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: forecast.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final f = forecast[index];
              return Container(
                width: 90,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(f["day"], style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 6),
                    const Icon(Icons.cloud, size: 28),
                    const SizedBox(height: 6),
                    Text(
                      f["temp"],
                      style:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text("${f["rain"]} rain",
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // =============================
  // SOIL DATA SECTION
  // =============================
  Widget _soilSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Soil Status",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12),
          Text("• Soil Moisture: 62%"),
          Text("• UV Index: Moderate (5)"),
          Text("• Ideal Watering Time: 6 AM - 8 AM"),
        ],
      ),
    );
  }

  // =============================
  // ALERTS SECTION
  // =============================
  Widget _alertsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Alerts",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 12),
          Text("⚠️ High rainfall expected in the next 48 hours."),
          Text("⚠️ Wind speed may increase in the evening."),
        ],
      ),
    );
  }
}
