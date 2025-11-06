import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Services/weather_services.dart'; // your weather_services.dart
import 'package:intl/intl.dart';

class ForecastDashboard extends StatefulWidget {
  final double lat;
  final double lon;
  final DateTime selectedDay;
  final String locationName;

  const ForecastDashboard({
    super.key,
    required this.lat,
    required this.lon,
    required this.selectedDay,
    required this.locationName,
  });

  @override
  State<ForecastDashboard> createState() => _ForecastDashboardState();
}

class _ForecastDashboardState extends State<ForecastDashboard> {
  final WeatherService weatherService = WeatherService();
  List<Map<String, dynamic>> hourlyData = [];
  String selectedMetric = "temperature";
  bool isLoading = true;

  List<String> favoriteLocations = ["New York", "Tokyo", "Paris"];
  late String selectedLocation;

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.locationName;
    fetchHourly();
  }

  Future<void> fetchHourly() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await weatherService.getHourlyForecast(
        widget.lat,
        widget.lon,
        widget.selectedDay,
      );
      setState(() {
        hourlyData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching hourly forecast: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Prepare graph spots
    List<FlSpot> spots = [];
    for (int i = 0; i < hourlyData.length; i++) {
      double yValue;
      if (selectedMetric == 'temperature') {
        yValue = hourlyData[i]['temp'].toDouble();
      } else if (selectedMetric == 'wind') {
        yValue = hourlyData[i]['wind'].toDouble();
      } else {
        yValue = hourlyData[i]['rain'].toDouble();
      }
      spots.add(FlSpot(i.toDouble(), yValue));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Hourly Forecast - $selectedLocation"),
        actions: [
          IconButton(icon: const Icon(Icons.location_city), onPressed: _showLocationSelector),
        ],
      ),
      body: Column(
        children: [
          // ===== Favorite Location Toggle =====
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Location: $selectedLocation",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    favoriteLocations.contains(selectedLocation)
                        ? Icons.star
                        : Icons.star_border,
                  ),
                  onPressed: () {
                    setState(() {
                      if (favoriteLocations.contains(selectedLocation)) {
                        favoriteLocations.remove(selectedLocation);
                      } else {
                        favoriteLocations.add(selectedLocation);
                      }
                    });
                  },
                ),
              ],
            ),
          ),

          // ===== Metric Selector =====
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['temperature', 'wind', 'precipitation'].map((metric) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedMetric = metric;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedMetric == metric ? Colors.blue : Colors.grey,
                  ),
                  child: Text(
                      metric[0].toUpperCase() + metric.substring(1)),
                ),
              );
            }).toList(),
          ),

          // ===== Current Value =====
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              selectedMetric == 'temperature'
                  ? "Current Temp: ${hourlyData[0]['temp']}°C"
                  : selectedMetric == 'wind'
                      ? "Current Wind: ${hourlyData[0]['wind']} m/s"
                      : "Current Rain: ${hourlyData[0]['rain']} mm",
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // ===== Hourly Graph =====
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.blue,
                      dotData: FlDotData(show: true),
                    )
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int idx = value.toInt();
                          if (idx >= 0 && idx < hourlyData.length) {
                            return Text(hourlyData[idx]['time']);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Location Selector =====
  void _showLocationSelector() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: 250,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Select a location",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView(
                  children: favoriteLocations.map((loc) {
                    return ListTile(
                      title: Text(loc),
                      onTap: () {
                        setState(() {
                          selectedLocation = loc;
                          // TODO: Fetch lat/lon for this location and call fetchHourly()
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
