import 'package:flutter/material.dart';
import '../../Services/location_service.dart';
import '../../Services/weather_services.dart';
import '../../Services/aqi_service.dart';

class DailyPlannerDashboard extends StatefulWidget {
  const DailyPlannerDashboard({super.key});

  @override
  State<DailyPlannerDashboard> createState() => _DailyPlannerDashboardState();
}

class _DailyPlannerDashboardState extends State<DailyPlannerDashboard> {
  String currentPlace = "Loading...";
  double temp = 0.0;
  int aqi = 50;
  bool isLoading = true;
  List<Map<String, dynamic>> hourlyForecast = [];
  Map<String, dynamic>? currentWeather;

  @override
  void initState() {
    super.initState();
    _initDailyPlanner();
  }

  Future<void> _initDailyPlanner() async {
    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos != null) {
        final weatherData =
            await WeatherService.getCurrentWeather(pos.latitude, pos.longitude);
        final forecastData = await WeatherService.getWeatherForecast(
            pos.latitude, pos.longitude);
        final aqiService = AQIService();
        final aqiData = await aqiService.getAQI(pos.latitude, pos.longitude);

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
      } else {
        setState(() {
          currentPlace = "Location unavailable";
          temp = 25.0;
          aqi = 50;
        });
      }
    } catch (e) {
      // Error initializing daily planner: $e
      setState(() {
        currentPlace = "Error loading location";
        temp = 25.0;
        aqi = 50;
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
    await _initDailyPlanner();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Daily Planner"),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Quick actions for daily planning
          showModalBottomSheet(
            context: context,
            builder: (context) => _buildQuickActions(),
          );
        },
        backgroundColor: Colors.teal.shade700,
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
                  _buildBestTimeWindows(),
                  const SizedBox(height: 16),
                  _buildNextWeatherCountdown(),
                  const SizedBox(height: 16),
                  _buildQuickTaskAdvisor(),
                  const SizedBox(height: 16),
                  _buildRiskScore(),
                  const SizedBox(height: 16),
                  _buildWhatToCarry(),
                  const SizedBox(height: 16),
                  _buildDailySummary(),
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
            Icon(Icons.location_on, color: Colors.teal.shade700),
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
                  color: Colors.teal.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestTimeWindows() {
    final bestTimes = _getBestTimeSlots();

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
                Icon(Icons.access_time, color: Colors.teal.shade700),
                const SizedBox(width: 8),
                const Text(
                  "Best Time Windows",
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
                            color: Colors.teal.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.teal.shade300),
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              color: Colors.teal.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              )
            else
              const Text(
                "No optimal time windows found for today",
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextWeatherCountdown() {
    final nextChange = _getNextWeatherChange();

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
                Icon(Icons.timer, color: Colors.teal.shade700),
                const SizedBox(width: 8),
                const Text(
                  "Next Weather Change",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              nextChange,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTaskAdvisor() {
    final tasks = _getRecommendedTasks();

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
                Icon(Icons.task_alt, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text(
                  "Quick Task Advisor",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tasks
                  .map((task) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue.shade300),
                        ),
                        child: Text(
                          task,
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

  Widget _buildRiskScore() {
    final riskScore = _calculateRiskScore();
    final riskLevel = _getRiskLevel(riskScore);
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
                  "Today's Risk Score",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: riskScore / 100,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(riskColor),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "$riskScore/100",
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

  Widget _buildWhatToCarry() {
    final items = _getWhatToCarry();

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
                Icon(Icons.backpack, color: Colors.green.shade700),
                const SizedBox(width: 8),
                const Text(
                  "What to Carry",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items
                  .map((item) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Text(
                          item,
                          style: TextStyle(
                            color: Colors.green.shade800,
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

  Widget _buildDailySummary() {
    final summary = _getDailySummary();

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
                Icon(Icons.summarize, color: Colors.purple.shade700),
                const SizedBox(width: 8),
                const Text(
                  "Daily Summary",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              summary,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Quick Actions",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _quickActionButton(Icons.calendar_view_day, "Schedule", () {}),
              _quickActionButton(Icons.checklist, "Tasks", () {}),
              _quickActionButton(Icons.notifications, "Reminders", () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickActionButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        FloatingActionButton(
          onPressed: onTap,
          backgroundColor: Colors.teal.shade700,
          child: Icon(icon),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // Helper methods
  List<String> _getBestTimeSlots() {
    if (hourlyForecast.isEmpty) return [];

    final bestTimes = <String>[];
    final now = DateTime.now();

    for (int i = 0; i < hourlyForecast.length && bestTimes.length < 4; i++) {
      final forecast = hourlyForecast[i];
      final temp = forecast['temperature'] as double;
      final rain = forecast['rainMm'] as double;

      if (temp >= 15 && temp <= 30 && rain < 1.0) {
        final time = now.add(Duration(hours: i));
        bestTimes.add("${time.hour.toString().padLeft(2, '0')}:00");
      }
    }

    return bestTimes;
  }

  String _getNextWeatherChange() {
    if (hourlyForecast.isEmpty || currentWeather == null) {
      return "No forecast data available";
    }

    final currentDesc = currentWeather!['description'].toString().toLowerCase();

    for (int i = 0; i < hourlyForecast.length; i++) {
      final forecast = hourlyForecast[i];
      final desc = forecast['description'].toString().toLowerCase();

      if (desc != currentDesc) {
        final hours = i + 1;
        return "Weather change in $hours hour${hours > 1 ? 's' : ''} (${desc.toUpperCase()})";
      }
    }

    return "No significant changes expected today";
  }

  List<String> _getRecommendedTasks() {
    if (currentWeather == null) return ["General outdoor activities"];

    final currentTemp = temp;
    final rain = currentWeather!['rainMm'] as double;

    if (currentTemp < 10) {
      return ["Indoor activities", "Online shopping", "Home projects"];
    } else if (currentTemp > 30) {
      return ["Stay hydrated", "Indoor work", "Evening activities"];
    } else if (rain > 5) {
      return ["Online tasks", "Indoor entertainment", "Virtual meetings"];
    } else {
      return ["Outdoor activities", "Exercise", "Social gatherings"];
    }
  }

  int _calculateRiskScore() {
    int score = 50; // Base score

    if (currentWeather != null) {
      final currentTemp = temp;
      final wind = currentWeather!['windSpeed'] as double;
      final rain = currentWeather!['rainMm'] as double;

      // Temperature risk
      if (currentTemp < 5 || currentTemp > 35) {
        score += 20;
      } else if (currentTemp < 10 || currentTemp > 30) {
        score += 10;
      }

      // Wind risk
      if (wind > 20) {
        score += 15;
      } else if (wind > 10) {
        score += 5;
      }

      // Rain risk
      if (rain > 10) {
        score += 20;
      } else if (rain > 2) {
        score += 10;
      }
    }

    // AQI risk
    if (aqi > 100) {
      score += 20;
    } else if (aqi > 50) {
      score += 10;
    }

    return score.clamp(0, 100);
  }

  String _getRiskLevel(int score) {
    if (score >= 80) return "High Risk";
    if (score >= 60) return "Medium Risk";
    if (score >= 40) return "Low Risk";
    return "Very Low Risk";
  }

  Color _getRiskColor(String level) {
    switch (level) {
      case "High Risk":
        return Colors.red;
      case "Medium Risk":
        return Colors.orange;
      case "Low Risk":
        return Colors.yellow.shade700;
      default:
        return Colors.green;
    }
  }

  List<String> _getWhatToCarry() {
    final items = <String>[];

    if (currentWeather == null) return ["Water bottle", "Phone"];

    final currentTemp = temp;
    final rain = currentWeather!['rainMm'] as double;
    final desc = currentWeather!['description'].toString().toLowerCase();

    // Temperature-based items
    if (currentTemp < 15) {
      items.add("Jacket");
      items.add("Warm clothes");
    } else if (currentTemp > 25) {
      items.add("Sunglasses");
      items.add("Hat");
    }

    // Weather-based items
    if (rain > 2 || desc.contains('rain')) {
      items.add("Umbrella");
      items.add("Raincoat");
    }

    if (desc.contains('sun') || currentTemp > 20) {
      items.add("Sunscreen");
    }

    // Always include essentials
    items.add("Water bottle");
    items.add("Phone");

    return items.take(6).toList(); // Limit to 6 items
  }

  String _getDailySummary() {
    if (currentWeather == null) return "Weather data loading...";

    final currentTemp = temp;
    final desc = currentWeather!['description'].toString();
    final rain = currentWeather!['rainMm'] as double;
    final humidity = currentWeather!['humidity'] as int;

    String summary =
        "Today features $desc weather with temperatures around ${currentTemp.toStringAsFixed(0)}°C. ";

    if (rain > 0) {
      summary += "Expect ${rain.toStringAsFixed(1)}mm of precipitation. ";
    }

    summary += "Humidity is at $humidity%. ";

    if (currentTemp < 15) {
      summary += "Dress warmly and consider indoor activities.";
    } else if (currentTemp > 25) {
      summary += "Stay hydrated and protect yourself from the sun.";
    } else {
      summary += "Perfect weather for outdoor activities!";
    }

    return summary;
  }
}
