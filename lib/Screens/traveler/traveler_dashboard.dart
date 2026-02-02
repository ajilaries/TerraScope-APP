import 'package:flutter/material.dart';
import '../../Services/location_service.dart';
import '../../Services/weather_services.dart';
import '../../Services/aqi_service.dart';
import 'traveler_quick_actions.dart';
import 'traveler_alerts.dart';
import 'traveler_saftey_card.dart';
import 'traveler_hourly_route.dart';
import 'traveler_map_preview.dart';

class TravelerDashboard extends StatefulWidget {
  const TravelerDashboard({super.key});

  @override
  State<TravelerDashboard> createState() => _TravelerDashboardState();
}

class _TravelerDashboardState extends State<TravelerDashboard> {
  String currentPlace = "Loading...";
  double temp = 0.0;
  int aqi = 50;
  bool isLoading = true;
  List<Map<String, dynamic>> hourlyForecast = [];
  Map<String, dynamic>? currentWeather;
  int travelerSafety = 75;
  List<Map<String, String>> routeAlerts = [];

  @override
  void initState() {
    super.initState();
    _initTraveler();
  }

  Future<void> _initTraveler() async {
    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos != null) {
        final weatherData =
            await WeatherService.getCurrentWeatherCached(pos.latitude, pos.longitude);
        final forecastData = await WeatherService.getWeatherForecastCached(
            pos.latitude, pos.longitude);
        final aqiService = AQIService();
        final aqiData = await aqiService.getAQI(pos.latitude, pos.longitude);
        final alerts =
            await WeatherService.getAnomalies(pos.latitude, pos.longitude);

        if (weatherData != null) {
          setState(() {
            currentPlace = weatherData['name'] ?? "Unknown Location";
            temp = (weatherData['main']['temp'] as num).toDouble();
            currentWeather = WeatherService.parseWeatherData(weatherData);
          });
        }

        if (forecastData != null && forecastData['list'] != null) {
          setState(() {
            hourlyForecast = (forecastData['list'] as List)
                .take(24)
                .map((item) => WeatherService.parseWeatherData(item))
                .toList();
          });
        }

        if (aqiData != null) {
          setState(() {
            aqi = aqiData;
          });
        }

        // Calculate traveler safety score
        setState(() {
          travelerSafety = _calculateTravelerSafety();
          routeAlerts = (alerts is List<dynamic>)
              ? alerts
                  .map((alert) => {
                        'title':
                            (alert)['event'] ?? 'Alert',
                        'description':
                            (alert)['description'] ??
                                'Description',
                        'time': 'Now',
                        'type': 'weather'
                      })
                  .cast<Map<String, String>>()
                  .toList()
              : [];
        });
      } else {
        setState(() {
          currentPlace = "Location unavailable";
          temp = 25.0;
          aqi = 50;
          travelerSafety = 50;
        });
      }
    } catch (e) {
      setState(() {
        currentPlace = "Error loading location";
        temp = 25.0;
        aqi = 50;
        travelerSafety = 50;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await _initTraveler();
  }

  int _calculateTravelerSafety() {
    int score = 70; // Base score for travelers

    if (currentWeather != null) {
      final currentTemp = temp;
      final wind = currentWeather!['windSpeed'] as double;
      final rain = currentWeather!['rainMm'] as double;
      final visibility = currentWeather!['visibility'] as double;

      // Temperature risk for travel
      if (currentTemp < 5 || currentTemp > 35) {
        score -= 20;
      } else if (currentTemp < 10 || currentTemp > 30) {
        score -= 10;
      }

      // Wind risk
      if (wind > 25) {
        score -= 25;
      } else if (wind > 15) {
        score -= 15;
      }

      // Rain risk
      if (rain > 10) {
        score -= 20;
      } else if (rain > 2) {
        score -= 10;
      }

      // Visibility risk
      if (visibility < 1000) {
        score -= 15;
      } else if (visibility < 5000) {
        score -= 5;
      }
    }

    // AQI risk
    if (aqi > 150) {
      score -= 25;
    } else if (aqi > 100) {
      score -= 15;
    } else if (aqi > 50) {
      score -= 5;
    }

    return score.clamp(0, 100);
  }

  void _openQuickActions() {
    TravelerQuickActions.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Traveler Mode"),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openQuickActions,
        backgroundColor: Colors.green.shade700,
        child: const Icon(Icons.flash_on_rounded, size: 28),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Weather Header
                  _buildCurrentWeatherHeader(),
                  const SizedBox(height: 20),

                  // Feature Cards
                  TravelerSafetyCard(score: travelerSafety),
                  const SizedBox(height: 16),
                  _buildTravelRiskAssessment(),
                  const SizedBox(height: 16),
                  _buildBestTravelTimes(),
                  const SizedBox(height: 16),
                  TravelerHourlyRoute(hourlyRoute: _getHourlyRoute()),
                  const SizedBox(height: 16),
                  TravelerAlerts(routeAlerts: routeAlerts),
                  const SizedBox(height: 16),
                  _buildTravelTips(),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentWeatherHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.location_on, color: Colors.green.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentPlace,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${temp.toStringAsFixed(1)}°C • AQI: $aqi",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (currentWeather != null)
              Text(
                currentWeather!['description'].toString().toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelRiskAssessment() {
    final riskLevel = _getTravelRiskLevel(travelerSafety);
    final riskColor = _getRiskColor(riskLevel);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: riskColor),
                const SizedBox(width: 8),
                const Text(
                  "Travel Risk Assessment",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: travelerSafety / 100,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(riskColor),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "$travelerSafety/100",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: riskColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              riskLevel,
              style: TextStyle(
                fontSize: 14,
                color: riskColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestTravelTimes() {
    final bestTimes = _getBestTravelTimes();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.green.shade700),
                const SizedBox(width: 8),
                const Text(
                  "Best Travel Times",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (bestTimes.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: bestTimes
                    .map((time) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              )
            else
              const Text(
                "No optimal travel times found for today",
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelTips() {
    final tips = _getTravelTips();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text(
                  "Travel Tips",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tips
                  .map((tip) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue.shade300),
                        ),
                        child: Text(
                          tip,
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getHourlyRoute() {
    if (hourlyForecast.isEmpty) {
      return [
        {'time': 'Now', 'temp': '${temp.toInt()}°C', 'weather': 'Clear'},
        {'time': '1h', 'temp': '${(temp + 1).toInt()}°C', 'weather': 'Cloudy'},
        {'time': '2h', 'temp': '${(temp + 2).toInt()}°C', 'weather': 'Rain'},
      ];
    }

    return hourlyForecast.take(6).map((forecast) {
      final time =
          DateTime.now().add(Duration(hours: hourlyForecast.indexOf(forecast)));
      return {
        'time': '${time.hour.toString().padLeft(2, '0')}:00',
        'temp': '${forecast['temperature'].toStringAsFixed(0)}°C',
        'weather': forecast['description'].toString(),
      };
    }).toList();
  }

  List<String> _getBestTravelTimes() {
    if (hourlyForecast.isEmpty) return [];

    final bestTimes = <String>[];
    final now = DateTime.now();

    for (int i = 0; i < hourlyForecast.length && bestTimes.length < 4; i++) {
      final forecast = hourlyForecast[i];
      final temp = forecast['temperature'] as double;
      final rain = forecast['rainMm'] as double;
      final wind = forecast['windSpeed'] as double;

      if (temp >= 10 && temp <= 30 && rain < 2.0 && wind < 15) {
        final time = now.add(Duration(hours: i));
        bestTimes.add("${time.hour.toString().padLeft(2, '0')}:00");
      }
    }

    return bestTimes;
  }

  List<String> _getTravelTips() {
    final tips = <String>["Check weather before departure"];

    if (currentWeather != null) {
      final currentTemp = temp;
      final rain = currentWeather!['rainMm'] as double;
      final wind = currentWeather!['windSpeed'] as double;

      if (currentTemp < 15) {
        tips.add("Dress warmly for cold weather");
      } else if (currentTemp > 25) {
        tips.add("Stay hydrated in hot weather");
      }

      if (rain > 2) {
        tips.add("Carry rain protection");
      }

      if (wind > 10) {
        tips.add("Be cautious of strong winds");
      }

      if (aqi > 50) {
        tips.add("Wear mask for poor air quality");
      }
    }

    return tips.take(6).toList();
  }

  String _getTravelRiskLevel(int score) {
    if (score >= 80) return "Very Safe";
    if (score >= 60) return "Safe";
    if (score >= 40) return "Moderate Risk";
    return "High Risk";
  }

  Color _getRiskColor(String level) {
    switch (level) {
      case "Very Safe":
        return Colors.green;
      case "Safe":
        return Colors.blue;
      case "Moderate Risk":
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}
