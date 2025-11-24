import 'package:flutter/material.dart';
import 'farmer_weather_details.dart';
import 'farmer_crop_health.dart';
import 'crop_recommendation.dart';
import 'farmer_soil_analysis.dart';
import 'farmer_alerts_screen.dart';
import 'farmer_crop_suitability.dart'; // ✅ FIXED IMPORT

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

      // ⭐ Drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green.shade700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    "Farmer Menu",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Terrascope Farmer Mode",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            _drawerItem(
              icon: Icons.dashboard,
              label: "Dashboard",
              onTap: () => Navigator.pop(context),
            ),

            _drawerItem(
              icon: Icons.health_and_safety,
              label: "Crop Health",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FarmerCropHealth()),
                );
              },
            ),

            _drawerItem(
              icon: Icons.recommend,
              label: "Crop Recommendations",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CropRecommendationScreen(),
                  ),
                );
              },
            ),
            _drawerItem(
              icon: Icons.notifications_active,
               label: "alerts",
                onTap: (){
                  Navigator.push(context,
                   MaterialPageRoute(
                    builder: (_)=> const FarmerAlertsScreen(),
                    ),
                    );
                },
            ),
              

            _drawerItem(
              icon: Icons.wb_sunny,
              label: "Weather Details",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FarmerWeatherDetails(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _weatherHeader(),
            const SizedBox(height: 20),

            _quickButtons(), // ⭐ NEW SECTION
            const SizedBox(height: 20),

            _recommendationSection(),
            const SizedBox(height: 20),

            _forecastSection(),
            const SizedBox(height: 20),

            _soilSection(),
            const SizedBox(height: 20),

            _alertsSection(),
          ],
        ),
      ),
    );
  }

  // Drawer Tile Widget
  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade700),
      title: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  // WEATHER HEADER
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

          const SizedBox(height: 20),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FarmerWeatherDetails(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "View Weather Details",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
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
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ⭐ Quick Navigation Buttons (NEW)
  Widget _quickButtons() {
    return Row(
      children: [
        Expanded(
          child: _quickCard(
            title: "Crop Health",
            icon: Icons.monitor_heart,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FarmerCropHealth()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickCard(
            title: "Recommendations",
            icon: Icons.recommend,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CropRecommendationScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _quickCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.green),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // RECOMMENDATION SECTION
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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

  // WEEKLY FORECAST
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${f["rain"]} rain",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // SOIL DATA
  Widget _soilSection() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FarmerSoilAnalysis()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:const  [
            Text(
              "soil status",
              style: TextStyle(fontSize: 18,fontWeight: FontWeight.w700),

            ),
            SizedBox(height: 12),
            Text("Soil moisture:62"),
            Text("Uv index:moderate (5)"),
            Text("ideal watering time:6Am-* am"),
            SizedBox(height: 6),
            Text(
              "Tap to view full soil analysis",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            )

          ],
        ),
      ),
    );
  }

  // ALERTS
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
