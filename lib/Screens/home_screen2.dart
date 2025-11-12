import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';
import '../Services/weather_services.dart';
import '../Services/location_service.dart';
import '../Screens/forecast_dashboard.dart';
import '../Screens/radar_screen.dart';
import '../Screens/anomalies_screen.dart';
import '../Screens/panic_screen.dart';
import '../utils/background_helper.dart';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  State<HomeScreen2> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {
  double lat = 0.0;
  double lon = 0.0;

  String locationName = "Loading...";
  String temperature = "---°C";
  String humidity = "--%";
  String wind = "-- km/h";
  String uvIndex = "--";
  String aqi = "--";
  String lastUpdated = "—";
  String weatherCondition = "Fetching...";
  IconData weatherIcon = WeatherIcons.cloud;
  String backgroundImage = 'lib/assets/images/default.jpg';

  bool isLoading = true;
 final WeatherService weatherService = WeatherService();


  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  Future<void> _fetchHomeData() async {
    setState(() => isLoading = true);

    try {
      final locData = await LocationService().getCurrentLocation();
      lat = locData['latitude'] ?? 0.0;
      lon = locData['longitude'] ?? 0.0;
      locationName = "${locData['city'] ?? 'Unknown'}, ${locData['country'] ?? ''}";

      // Snappy placeholder
      setState(() {
        weatherCondition = "Fetching...";
        temperature = "---°C";
        humidity = "--%";
        wind = "-- km/h";
        uvIndex = "--";
        aqi = "--";
        weatherIcon = WeatherIcons.cloud;
        backgroundImage = getBackgroundImage(weatherCondition);
      });

      // Fetch weather + AQI
      final weatherData = await weatherService.getWeatherData(
        token: "dummy_token", // replace later if needed
        lat: lat,
        lon: lon,
      );

      final aqiData = await weatherService.getAQIData(lat: lat, lon: lon);

      setState(() {
        temperature =
            "${(weatherData['temperature'] ?? 0).toStringAsFixed(1)}°C";
        humidity = "${weatherData['humidity'] ?? '--'}%";
        wind = "${weatherData['wind_speed'] ?? '--'} km/h";
        uvIndex = (weatherData['uv']?.toString() ?? "--");
        aqi = (aqiData['aqi']?.toString() ?? "--");
        weatherCondition = weatherData['condition'] ?? "Unknown";
        weatherIcon = weatherService.getWeatherIcon(weatherCondition);
        backgroundImage = weatherService.getBackgroundImage(weatherCondition);
        lastUpdated = DateFormat('hh:mm a').format(DateTime.now());
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching home data: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchHomeData,
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
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Location & Updated Time
                        Text(
                          locationName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Last updated: $lastUpdated",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 20),

                        // Weather Card
                        Card(
                          color: Colors.white24,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                BoxedIcon(weatherIcon,
                                    size: 64, color: Colors.white),
                                const SizedBox(height: 8),
                                Text(
                                  temperature,
                                  style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Text(
                                  weatherCondition.toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.white70),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _infoColumn("Humidity", humidity),
                                    _infoColumn("Wind", wind),
                                    _infoColumn("UV Index", uvIndex),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _infoColumn("Air Quality", aqi,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Quick Access Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _quickButton("Forecast", Icons.calendar_today, () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ForecastDashboard(
                                            lat: lat,
                                            lon: lon,
                                            selectedDay: DateTime.now(),
                                            locationName: locationName,
                                          )));
                            }),
                            _quickButton("Radar", Icons.map, () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          RadarScreen(lat: lat, lon: lon)));
                            }),
                            _quickButton("Alerts", Icons.warning, () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => AnomaliesScreen(
                                            lat: lat,
                                            lon: lon,
                                          )));
                            }),
                            _quickButton("Panic", Icons.sos, () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const PanicScreen()));
                            }),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _infoColumn(String label, String value,
      {double fontSize = 14, FontWeight fontWeight = FontWeight.normal}) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(color: Colors.white70, fontSize: fontSize - 2)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: fontWeight)),
      ],
    );
  }
}
