import 'package:flutter/material.dart';
import '../Services/weather_services.dart';
import '../Services/location_service.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart'; // For simple temperature line chart
import 'package:weather_icons/weather_icons.dart';

class Home0 extends StatefulWidget {
  const Home0({super.key});

  @override
  State<Home0> createState() => _Home0State();
}

class _Home0State extends State<Home0> {
  List<Map<String, dynamic>> forecast = [];
  bool isLoading = true;
  String lastUpdated = '—';
  String backgroundImage = 'lib/assets/images/default.jpg';

  @override
  void initState() {
    super.initState();
    fetchForecast();
  }

  Future<void> fetchForecast() async {
    setState(() => isLoading = true);
    try {
      final locationData = await LocationService().getCurrentLocation();
      final lat = locationData['latitude'];
      final lon = locationData['longitude'];

      final realForecast = await WeatherService().getFiveDayForecast(lat, lon);

      setState(() {
        forecast = realForecast;
        lastUpdated = DateFormat('hh:mm a').format(DateTime.now());
        backgroundImage = forecast.isNotEmpty
            ? WeatherService().getBackgroundImage(
                realForecast[0]['icon'].toString(),
              ) // first day's icon
            : 'lib/assets/images/default.jpg';
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching forecast: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: fetchForecast,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(backgroundImage, fit: BoxFit.cover),
            ),
            Container(color: Colors.black.withOpacity(0.3)),
            SafeArea(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Last updated: $lastUpdated",
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "5-Day Forecast",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: forecast.length,
                                itemBuilder: (context, index) {
                                  final dayForecast = forecast[index];
                                  return Container(
                                    width: 120,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          dayForecast['day'],
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        BoxedIcon(
                                          dayForecast['icon'],
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "${dayForecast['temp'].toStringAsFixed(1)}°C",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Optional: humidity and wind (if available)
                                        if (dayForecast.containsKey('humidity'))
                                          Text(
                                            "💧 ${dayForecast['humidity']}%",
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        if (dayForecast.containsKey('wind'))
                                          Text(
                                            "🌬️ ${dayForecast['wind']} km/h",
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Optional temperature trend chart
                            if (forecast.isNotEmpty)
                              SizedBox(
                                height: 150,
                                child: LineChart(
                                  LineChartData(
                                    borderData: FlBorderData(show: false),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            int index = value.toInt();
                                            if (index >= 0 &&
                                                index < forecast.length) {
                                              return Text(
                                                forecast[index]['day'],
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12,
                                                ),
                                              );
                                            }
                                            return const Text('');
                                          },
                                          interval: 1,
                                        ),
                                      ),
                                    ),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: forecast
                                            .asMap()
                                            .entries
                                            .map(
                                              (e) => FlSpot(
                                                e.key.toDouble(),
                                                e.value['temp'].toDouble(),
                                              ),
                                            )
                                            .toList(),
                                        isCurved: true,
                                        color: Colors.orangeAccent,
                                        barWidth: 3,
                                        dotData: FlDotData(show: true),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
