import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Services/weather_services.dart'; // your updated weather_services.dart
import '../Services/device_service.dart'; // for token handling
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
  double lat = 0.0;
  double lon = 0.0;

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.locationName;
    lat = widget.lat;
    lon = widget.lon;
    fetchHourly();
  }

  Future<void> fetchHourly() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Get device token
      String token = DeviceService.getDeviceToken();

      final data = await weatherService.getHourlyForecast(
        token: token,
        lat: lat,
        lon: lon,
        day: widget.selectedDay,
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
          IconButton(
            icon: const Icon(Icons.location_city),
            onPressed: _showLocationSelector,
          ),
        ],
      ),
      body: Column(
        children: [
          // Favorite Location Toggle
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

          // Metric Selector
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
                  child: Text(metric[0].toUpperCase() + metric.substring(1)),
                ),
              );
            }).toList(),
          ),

          // Current Value
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              hourlyData.isNotEmpty
                  ? selectedMetric == 'temperature'
                      ? "Current Temp: ${hourlyData[0]['temp']}°C"
                      : selectedMetric == 'wind'
                          ? "Current Wind: ${hourlyData[0]['wind']} m/s"
                          : "Current Rain: ${hourlyData[0]['rain']} mm"
                  : "No data",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // Hourly Graph
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: hourlyData.isNotEmpty
                  ? LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            barWidth: 3,
                            color: Colors.blue,
                            dotData: FlDotData(show: true),
                          ),
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
                    )
                  : const Center(child: Text("No hourly data available")),
            ),
          ),
        ],
      ),
    );
  }

  // Location Selector
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
                      onTap: () async {
                        setState(() {
                          selectedLocation = loc;
                        });

                        // TODO: Replace with actual lat/lon for selected location
                        // Example: call your API or lookup table
                        double newLat = lat; // placeholder
                        double newLon = lon; // placeholder

                        setState(() {
                          lat = newLat;
                          lon = newLon;
                        });

                        await fetchHourly();
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
