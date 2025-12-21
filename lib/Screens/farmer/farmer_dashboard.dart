import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'farmer_weather_details.dart';
import 'farmer_crop_health.dart';
import 'crop_recommendation.dart';
import 'farmer_soil_analysis.dart';
import 'farmer_alerts_screen.dart';
import 'farmer_crop_suitability.dart';
import 'package:terra_scope_apk/Services/location_service.dart';
import 'package:terra_scope_apk/Services/crop_service.dart';
import 'package:terra_scope_apk/Services/ai_predict_service.dart';

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
  late double latitude;
  late double longitude;
  late String soilType;

  Map<String, dynamic> weatherData = {};
  Map<String, dynamic> locationData = {};
  List<Map<String, dynamic>> cropRecommendations = [];
  List<Prediction> predictions = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    latitude = widget.latitude ?? 0.0;
    longitude = widget.longitude ?? 0.0;
    soilType = widget.soilType ?? "Unknown";

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // If location not provided, fetch current location
      if (latitude == 0.0 && longitude == 0.0) {
        final locationService = LocationService();
        final loc = await locationService.getCurrentLocation();
        latitude = loc["latitude"];
        longitude = loc["longitude"];
        locationData = loc;
      } else if (locationData.isEmpty) {
        final locationService = LocationService();
        locationData = await locationService.getCurrentLocation();
      }

      // Load crop data from JSON
      await CropService.loadCrops();

      // Fetch data in parallel with timeouts
      await Future.wait([
        _fetchWeatherDataWithTimeout(),
        _fetchCropRecommendations(),
      ], eagerError: false);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error loading data: $e";
        isLoading = false;
      });
      print("❌ Error: $e");
    }
  }

  /// Fetch weather with 5-second timeout
  Future<void> _fetchWeatherDataWithTimeout() async {
    try {
      final url = "https://api.weatherapi.com/v1/current.json"
          "?key=YOUR_WEATHERAPI_KEY&q=$latitude,$longitude&aqi=yes";

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print("⚠️ Weather API timeout, using fallback");
          return http.Response('{"error": "timeout"}', 408);
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            weatherData = data;
          });
        }
        print("✅ Weather data fetched");
      } else {
        print("⚠️ Weather API failed: ${response.statusCode}");
        _setFallbackWeather();
      }
    } catch (e) {
      print("⚠️ Weather fetch error: $e");
      _setFallbackWeather();
    }
  }

  /// Set fallback weather data
  void _setFallbackWeather() {
    if (mounted) {
      setState(() {
        weatherData = {
          "current": {
            "temp_c": 28.0,
            "condition": {"text": "Partly Cloudy"},
            "humidity": 65,
            "wind_kph": 12.0,
            "feelslike_c": 28.0,
          },
          "location": {
            "name": locationData['city'] ?? "Unknown",
            "region": locationData['state'] ?? "",
          }
        };
      });
    }
  }

  /// Fetch crop recommendations using ML
  Future<void> _fetchCropRecommendations() async {
    try {
      final state = locationData['state'] ?? "Maharashtra";
      final district = locationData['district'] ?? "Nashik";

      print("📍 Getting crops for: $state, $district");

      // Get crops from local JSON
      final crops = CropService.getDistrictCrops(state, district);

      if (crops != null && crops['crops'] != null) {
        final List<dynamic> cropList = crops['crops'] ?? [];
        List<Map<String, dynamic>> recs = [];

        for (var crop in cropList.take(5)) {
          recs.add({
            'name': crop['name'] ?? 'Unknown',
            'suitability': (crop['suitability'] as num?)?.toInt() ?? 80,
            'reason': crop['reason'] ?? 'Suitable for this region',
            'temp': crop['temp'] ?? '20-30°C',
            'soil': crop['soil'] ?? 'Any soil type',
          });
        }

        if (mounted) {
          setState(() {
            cropRecommendations = recs;
          });
        }
        print("✅ Crop recommendations loaded: ${recs.length} crops");
      } else {
        print("⚠️ No crops found, using defaults");
        _setDefaultCrops();
      }
    } catch (e) {
      print("❌ Crop recommendation error: $e");
      _setDefaultCrops();
    }
  }

  /// Default crop recommendations
  void _setDefaultCrops() {
    if (mounted) {
      setState(() {
        cropRecommendations = [
          {
            'name': 'Paddy',
            'suitability': 85,
            'reason': 'Well-suited for monsoon season',
            'temp': '20-35°C',
            'soil': 'Clay/Loam',
          },
          {
            'name': 'Wheat',
            'suitability': 78,
            'reason': 'Good for winter season',
            'temp': '10-25°C',
            'soil': 'Well-drained soil',
          },
        ];
      });
    }
  }

  String _getLocationName() {
    if (locationData.isNotEmpty) {
      return "${locationData['city'] ?? 'Unknown'}, ${locationData['state'] ?? ''}";
    }
    return "Your Location";
  }

  String _getTemperature() {
    if (weatherData.isNotEmpty && weatherData['current'] != null) {
      return weatherData['current']['temp_c'].toString();
    }
    return "28";
  }

  String _getWeatherCondition() {
    if (weatherData.isNotEmpty && weatherData['current'] != null) {
      return weatherData['current']['condition']['text'] ?? "Unknown";
    }
    return "Partly Cloudy";
  }

  int _getHumidity() {
    if (weatherData.isNotEmpty && weatherData['current'] != null) {
      return weatherData['current']['humidity'] ?? 65;
    }
    return 65;
  }

  double _getWindSpeed() {
    if (weatherData.isNotEmpty && weatherData['current'] != null) {
      return weatherData['current']['wind_kph'] ?? 12.0;
    }
    return 12.0;
  }

  int _getRainChance() {
    if (weatherData.isNotEmpty && weatherData['current'] != null) {
      return (weatherData['current']['chance_of_rain'] as num?)?.toInt() ?? 40;
    }
    return 40;
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
                    "Soil: $soilType",
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
            _getLocationName(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${_getTemperature()}°C",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getWeatherCondition(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniInfo(Icons.water_drop, "Humidity", "${_getHumidity()}%"),
              _miniInfo(
                  Icons.cloudy_snowing, "Rain Chance", "${_getRainChance()}%"),
              _miniInfo(Icons.air, "Wind",
                  "${_getWindSpeed().toStringAsFixed(1)} km/h"),
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
          children: [
            const Text(
              "Soil Status",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text("Soil Type: $soilType"),
            Text("Latitude: ${latitude.toStringAsFixed(4)}"),
            Text("Longitude: ${longitude.toStringAsFixed(4)}"),
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
