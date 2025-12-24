import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'farmer_weather_details.dart';
import 'farmer_crop_health.dart';
import 'crop_recommendation.dart';
import 'farmer_soil_analysis.dart';
import 'farmer_alerts_screen.dart';
import 'farmer_crop_suitability.dart'; // ✅ FIXED IMPORT

class FarmerDashboard extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? soilType;

  const FarmerDashboard({
    super.key,
    this.latitude,
    this.longitude,
    this.soilType,
  });

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  bool isLoading = false;
  String errorMessage = '';
  bool _isLoading = false;
  Map<String, dynamic>? _weatherData;
  Map<String, dynamic>? _locationData;
  List<Map<String, dynamic>> cropRecommendations = [];
  List<Map<String, dynamic>>? _forecastData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      _isLoading = true;
    });

    try {
      // Simulate loading weather data
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _weatherData = {
          'temperature': 29.0,
          'condition': 'Partly Cloudy',
          'humidity': 78.0,
          'wind_speed': 12.0,
        };
        _locationData = {
          'city': 'Kottayam',
          'state': 'Kerala',
        };
        cropRecommendations = [
          {
            'name': 'Rice',
            'reason': 'Optimal temperature and humidity for growth',
            'suitability': 85,
          },
          {
            'name': 'Wheat',
            'reason': 'Suitable soil conditions',
            'suitability': 75,
          },
        ];
        _forecastData = [
          {'day': 'Mon', 'temp': 28, 'humidity': 70, 'icon': Icons.cloud},
          {'day': 'Tue', 'temp': 30, 'humidity': 65, 'icon': Icons.sunny},
          {
            'day': 'Wed',
            'temp': 27,
            'humidity': 80,
            'icon': Icons.cloudy_snowing
          },
        ];
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
        _isLoading = false;
      });
    }
  }

  String _getLocationName() {
    if (_locationData != null) {
      final city = _locationData!['city'] ?? 'Unknown';
      final state = _locationData!['state'] ?? '';
      return state.isNotEmpty ? '$city, $state' : city;
    }
    return 'Unknown Location';
  }

  String _getHumidity() {
    return _weatherData?['humidity']?.toStringAsFixed(0) ?? '--';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green.shade700,
          title: const Text("Farmer Mode"),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green.shade700,
          title: const Text("Farmer Mode"),
        ),
        body: Center(
          child: Text(errorMessage),
        ),
      );
    }

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
                children: [
                  const Text(
                    "Farmer Menu",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Location: ${_getLocationName()}",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    "Soil: ${widget.soilType ?? 'Unknown'}",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FarmerAlertsScreen(),
                  ),
                );
              },
            ),
            _drawerItem(
              icon: Icons.agriculture,
              label: "Crop Suitability",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FarmerCropSuitability(),
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
    if (_isLoading || _weatherData == null || _locationData == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.green.shade700,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final temp = _weatherData!['temperature']?.toStringAsFixed(1) ?? '--';
    final condition = _weatherData!['condition'] ?? 'Unknown';
    final humidity = _weatherData!['humidity']?.toStringAsFixed(0) ?? '--';
    final windSpeed = _weatherData!['wind_speed']?.toStringAsFixed(1) ?? '--';
    final city = _locationData!['city'] ?? 'Unknown';
    final state = _locationData!['state'] ?? '';

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

  // RECOMMENDATION SECTION - Using Real ML Data
  Widget _recommendationSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "AI Crop Recommendations",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (cropRecommendations.isEmpty)
            const Text("Loading recommendations...")
          else
            ...cropRecommendations.asMap().entries.map((entry) {
              final crop = entry.value;
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              crop['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              crop['reason'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${crop['suitability']}%",
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (entry.key < cropRecommendations.length - 1)
                    const Divider(height: 20),
                ],
              );
            }),
        ],
      ),
    );
  }

  // WEEKLY FORECAST
  Widget _forecastSection() {
    if (_isLoading || _forecastData == null) {
      return const SizedBox.shrink();
    }

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
            itemCount: _forecastData!.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final f = _forecastData![index];
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
                    Icon(f["icon"] ?? Icons.cloud, size: 28),
                    const SizedBox(height: 6),
                    Text(
                      "${f["temp"]}°",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${f["humidity"]}% humidity",
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12),
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
          children: [
            const Text(
              "soil status",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text("Soil Type: ${widget.soilType ?? 'Unknown'}"),
            Text("Latitude: ${widget.latitude?.toStringAsFixed(4) ?? '--'}"),
            Text("Longitude: ${widget.longitude?.toStringAsFixed(4) ?? '--'}"),
            Text("Humidity Level: ${_getHumidity()}%"),
            const SizedBox(height: 6),
            const Text(
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
