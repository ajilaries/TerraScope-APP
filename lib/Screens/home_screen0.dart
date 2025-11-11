import 'package:flutter/material.dart';
import '../Services/weather_services.dart';
import '../Services/location_service.dart';
import '../Screens/forecast_dashboard.dart'; // Make sure path is correct
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:weather_icons/weather_icons.dart';
import '../utils/background_helper.dart';

class Home0 extends StatefulWidget {
  const Home0({super.key});

  @override
  State<Home0> createState() => _Home0State();
}

class _Home0State extends State<Home0> {
  double lat = 0.0;
  double lon = 0.0;

  List<Map<String, dynamic>> forecast = [];
  bool isLoading = true;
  String lastUpdated = '—';
  String backgroundImage = 'lib/assets/images/default.jpg';

  @override
  void initState() {
    super.initState();
    fetchForecast();
  }

  // Get token from LocationService or any stored source
String getDeviceToken() {
  // Check if LocationService has a stored token
  final token = LocationService().deviceToken;
  if (token != null && token.isNotEmpty) {
    return token;
  }

  // If no token exists, generate or request one (example)
  // You could also fetch it from SharedPreferences if you store it locally
  final newToken = "DEVICE_TOKEN_${DateTime.now().millisecondsSinceEpoch}";
  LocationService().deviceToken = newToken;
  return newToken;
}


  Future<void> fetchForecast() async {
    setState(() => isLoading = true);

    try {
      final locationData = await LocationService().getCurrentLocation();
      lat = locationData['latitude'] ?? 0.0;
      lon = locationData['longitude'] ?? 0.0;

      final realForecast = await WeatherService().getFiveDayForecast(
        token: getDeviceToken(),
        lat: lat,
        lon: lon,
      );

      setState(() {
        forecast = realForecast;
        lastUpdated = DateFormat('hh:mm a').format(DateTime.now());

        backgroundImage = forecast.isNotEmpty
            ? getBackgroundImage(realForecast[0]['condition'] ?? "Clear")
            : 'lib/assets/images/default.jpg';

        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching forecast: $e");
      setState(() => isLoading = false);
    }
  }

  DateTime _getSelectedDate(int index) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + index);
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
                                  return GestureDetector(
                                    onTap: () {
                                      final selectedDate = _getSelectedDate(index);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ForecastDashboard(
                                            lat: lat,
                                            lon: lon,
                                            selectedDay: selectedDate,
                                            locationName: "Current Location",
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 120,
                                      margin: const EdgeInsets.symmetric(horizontal: 8),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white30, width: 1),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            dayForecast['day'] ?? "",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          BoxedIcon(
                                            dayForecast['icon'] ?? WeatherIcons.na,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "${(dayForecast['temp'] ?? 0).toStringAsFixed(1)}°C",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
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
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (forecast.isNotEmpty)
                              SizedBox(
                                height: 150,
                                child: LineChart(
                                  LineChartData(
                                    borderData: FlBorderData(show: false),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: true),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            int index = value.toInt();
                                            if (index >= 0 && index < forecast.length) {
                                              return Text(
                                                forecast[index]['day'] ?? "",
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
                                        spots: forecast.asMap().entries.map((e) {
                                          final temp = (e.value['temp'] ?? 0).toDouble();
                                          return FlSpot(e.key.toDouble(), temp);
                                        }).toList(),
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
