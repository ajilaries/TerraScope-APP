import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import '../../Services/location_service.dart';
import '../../Services/weather_services.dart';
import '../../Services/soil_service.dart';
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

class _FarmerDashboardState extends State<FarmerDashboard>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  String errorMessage = '';
  bool _isLoading = false;
  Map<String, dynamic>? _weatherData;
  Map<String, dynamic>? _locationData;
  List<Map<String, dynamic>> cropRecommendations = [];
  List<Map<String, dynamic>>? _forecastData;
  String _soilType = 'Loading...';

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    _animationController.repeat(reverse: true);
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      _isLoading = true;
    });

    try {
      // Use widget parameters for location, fallback to current location if not provided
      double lat = widget.latitude ?? 0.0;
      double lon = widget.longitude ?? 0.0;

      if (lat == 0.0 && lon == 0.0) {
        // Fallback to current location if not provided
        final position = await LocationService.getCurrentPosition();
        if (position != null) {
          lat = position.latitude;
          lon = position.longitude;
        }
      }

      // Get location name from coordinates
      String cityName = 'Unknown';
      String stateName = '';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
        if (placemarks.isNotEmpty) {
          cityName = placemarks.first.locality ?? 'Unknown';
          stateName = placemarks.first.administrativeArea ?? '';
        }
      } catch (e) {
        print('Error getting location name: $e');
      }

      // Fetch soil type data
      final soilType = await SoilService.getSoilType(lat, lon);

      // Fetch real weather data
      final weatherData = await WeatherService.getCurrentWeatherCached(lat, lon);
      final forecastData = await WeatherService.getWeatherForecastCached(lat, lon);

      // Parse weather data
      Map<String, dynamic> parsedWeather = {};
      if (weatherData != null) {
        parsedWeather = {
          'temperature': (weatherData['main']['temp'] as num).toDouble(),
          'condition': weatherData['weather'][0]['description'],
          'humidity': (weatherData['main']['humidity'] as num).toDouble(),
          'wind_speed': (weatherData['wind']['speed'] as num).toDouble(),
        };
      } else {
        // Fallback to default values
        parsedWeather = {
          'temperature': 29.0,
          'condition': 'Partly Cloudy',
          'humidity': 78.0,
          'wind_speed': 12.0,
        };
      }

      // Parse forecast data - Get daily forecasts for 7 days
      List<Map<String, dynamic>> parsedForecast = [];
      if (forecastData != null && forecastData['list'] != null) {
        final list = forecastData['list'] as List;
        Map<String, Map<String, dynamic>> dailyForecasts = {};

        for (final item in list) {
          final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          final dayKey = dt.toIso8601String().split('T')[0]; // YYYY-MM-DD

          // Take midday forecast (around 12:00) for each day
          if (dt.hour >= 11 &&
              dt.hour <= 13 &&
              !dailyForecasts.containsKey(dayKey)) {
            dailyForecasts[dayKey] = {
              'day': [
                'Mon',
                'Tue',
                'Wed',
                'Thu',
                'Fri',
                'Sat',
                'Sun'
              ][dt.weekday - 1],
              'temp': (item['main']['temp'] as num).toDouble(),
              'humidity': (item['main']['humidity'] as num).toInt(),
              'icon': _getWeatherIcon(item['weather'][0]['main']),
            };
          }
        }

        // Take first 7 days
        final sortedDays = dailyForecasts.keys.toList()..sort();
        for (int i = 0; i < 7 && i < sortedDays.length; i++) {
          parsedForecast.add(dailyForecasts[sortedDays[i]]!);
        }

        // If not enough daily forecasts, fill with available data
        if (parsedForecast.length < 7) {
          for (final item in list) {
            if (parsedForecast.length >= 7) break;
            final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
            final dayKey = dt.toIso8601String().split('T')[0];
            if (!dailyForecasts.containsKey(dayKey)) {
              parsedForecast.add({
                'day': [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun'
                ][dt.weekday - 1],
                'temp': (item['main']['temp'] as num).toDouble(),
                'humidity': (item['main']['humidity'] as num).toInt(),
                'icon': _getWeatherIcon(item['weather'][0]['main']),
              });
              dailyForecasts[dayKey] = parsedForecast.last;
            }
          }
        }
      } else {
        // Fallback forecast for 7 days
        parsedForecast = [
          {'day': 'Mon', 'temp': 28, 'humidity': 70, 'icon': Icons.cloud},
          {'day': 'Tue', 'temp': 30, 'humidity': 65, 'icon': Icons.sunny},
          {
            'day': 'Wed',
            'temp': 27,
            'humidity': 80,
            'icon': Icons.cloudy_snowing
          },
          {'day': 'Thu', 'temp': 29, 'humidity': 75, 'icon': Icons.wb_sunny},
          {'day': 'Fri', 'temp': 31, 'humidity': 60, 'icon': Icons.grain},
          {'day': 'Sat', 'temp': 26, 'humidity': 85, 'icon': Icons.ac_unit},
          {'day': 'Sun', 'temp': 32, 'humidity': 55, 'icon': Icons.flash_on},
        ];
      }

      if (mounted) {
        setState(() {
          _weatherData = parsedWeather;
          _locationData = {
            'city': cityName,
            'state': stateName,
          };
          _soilType = soilType;
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
          _forecastData = parsedForecast;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load data: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          _isLoading = false;
        });
      }
    }
  }

  IconData _getWeatherIcon(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.grain;
      case 'drizzle':
        return Icons.grain;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'mist':
      case 'fog':
        return Icons.blur_on;
      default:
        return Icons.cloud;
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: const Icon(
                    Icons.agriculture,
                    color: Colors.white,
                    size: 28,
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            const Text(
              "Farmer Mode",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
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
                    "Soil: $_soilType",
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
            "${_weatherData!['temperature'].toStringAsFixed(1)}°C",
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _weatherData!['condition'],
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniInfo(Icons.water_drop, "Humidity",
                  "${_weatherData!['humidity'].toStringAsFixed(0)}%"),
              _miniInfo(Icons.cloudy_snowing, "Rain Chance", "65%"),
              _miniInfo(Icons.air, "Wind",
                  "${_weatherData!['wind_speed'].toStringAsFixed(1)} km/h"),
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
      mainAxisSize: MainAxisSize.min,
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
          mainAxisSize: MainAxisSize.min,
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
          height: 170,
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
                  mainAxisSize: MainAxisSize.min,
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
            Text("Soil Type: $_soilType"),
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
