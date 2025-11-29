import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Services/weather_services.dart';
import 'package:intl/intl.dart';

class ForecastDashboard extends StatefulWidget {
  final double lat;
  final double lon;
  final String locationName;
  final DateTime selectedDay;
  final String token;

  const ForecastDashboard({
    super.key,
    required this.lat,
    required this.lon,
    required this.locationName,
    required this.selectedDay,
    required this.token,
  });

  @override
  State<ForecastDashboard> createState() => _ForecastDashboardState();
}

class _ForecastDashboardState extends State<ForecastDashboard> {
  final WeatherService weatherService = WeatherService();

  List<Map<String, dynamic>> hourlyData = [];
  String selectedMetric = "temperature";
  bool isLoading = true;

  int highlightedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchHourly();
  }

  Future<void> fetchHourly() async {
    setState(() => isLoading = true);

    try {
      final data = await weatherService.getHourlyForecast(
        lat: widget.lat,
        lon: widget.lon,
      );

      setState(() {
        hourlyData = data;
        highlightedIndex = 0;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch hourly forecast: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (hourlyData.isEmpty) {
      return const Scaffold(body: Center(child: Text("No hourly data found")));
    }

    // Create spots for the selected metric
    final spots = List.generate(hourlyData.length, (i) {
      final d = hourlyData[i];

      final val = switch (selectedMetric) {
        "temperature" => (d["temp"] ?? 0).toDouble(),
        "wind" => (d["wind"] ?? 0).toDouble(),
        "precipitation" => (d["rain"] ?? 0).toDouble(),
        _ => 0.0,
      };

      return FlSpot(i.toDouble(), val);
    });

    final highlightedValue = spots[highlightedIndex].y;

    return Scaffold(
      appBar: AppBar(title: Text("Hourly Forecast • ${widget.locationName}")),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // Metric buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _metricBtn("temperature", "Temp"),
              _metricBtn("wind", "Wind"),
              _metricBtn("precipitation", "Rain"),
            ],
          ),

          const SizedBox(height: 20),

          // Big value display
          Text(
            _formatMetric(highlightedValue),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text(
            "at ${hourlyData[highlightedIndex]['time']}",
            style: const TextStyle(fontSize: 14),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: LineChart(
                LineChartData(
                  minY: _getMinValue(spots),
                  maxY: _getMaxValue(spots) * 1.3,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(),
                    handleBuiltInTouches: true,
                    touchCallback: (event, response) {
                      if (response != null &&
                          response.lineBarSpots != null &&
                          response.lineBarSpots!.isNotEmpty) {
                        setState(() {
                          highlightedIndex = response.lineBarSpots!.first.x
                              .toInt();
                        });
                      }
                    },
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 4,
                      dotData: FlDotData(show: true),
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.lightBlueAccent],
                      ),
                    ),
                  ],
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _getYAxisInterval(spots),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        getTitlesWidget: (value, meta) {
                          int i = value.toInt();
                          if (i >= hourlyData.length) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              hourlyData[i]["time"],
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
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

  // ---------------------- Helpers ----------------------

  Widget _metricBtn(String metric, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ElevatedButton(
        onPressed: () => setState(() => selectedMetric = metric),
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedMetric == metric ? Colors.blue : Colors.grey,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
        child: Text(label),
      ),
    );
  }

  String _formatMetric(double val) {
    return switch (selectedMetric) {
      "temperature" => "${val.toStringAsFixed(1)}°C",
      "wind" => "${val.toStringAsFixed(1)} m/s",
      "precipitation" => "${val.toStringAsFixed(1)} mm",
      _ => "$val",
    };
  }

  double _getMaxValue(List<FlSpot> s) =>
      s.map((e) => e.y).reduce((a, b) => a > b ? a : b);

  double _getMinValue(List<FlSpot> s) =>
      s.map((e) => e.y).reduce((a, b) => a < b ? a : b);

  double _getYAxisInterval(List<FlSpot> spots) {
    final max = _getMaxValue(spots);
    if (max <= 10) return 2;
    if (max <= 20) return 5;
    return 10;
  }
}
