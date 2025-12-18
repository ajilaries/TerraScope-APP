import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';
import '../Services/weather_services.dart';
import '../Services/location_service.dart';
import '../Screens/forecast_dashboard.dart';
import '../Screens/radar_screen.dart';
import '../Screens/anomaly_screen.dart';
import '../Screens/panic_screen.dart';

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
Timer? autoRefreshTimer;

@override
void initState() {
super.initState();
_fetchHomeData();

autoRefreshTimer = Timer.periodic(
  const Duration(seconds: 30),
      (timer) => _fetchHomeData(),
);

}

@override
void dispose() {
autoRefreshTimer?.cancel();
super.dispose();
}

Future<void> _fetchHomeData() async {
  if (!mounted) return;

  try {
    setState(() => isLoading = true);

    final position = await LocationService().getCurrentLocation();
    final latTemp = position["latitude"];
    final lonTemp = position["longitude"];

    final placeInfo =
        await LocationService().getLocationNameFromCoordinates(
      latTemp,
      lonTemp,
    );

    final weatherData = await weatherService.getWeatherData(
      token: "public_token",
      lat: latTemp,
      lon: lonTemp,
    );

    final aqiData =
        await weatherService.getAQIData(lat: latTemp, lon: lonTemp);

    setState(() {
      lat = latTemp;
      lon = lonTemp;
      locationName = "${placeInfo['city']}, ${placeInfo['country']}";

      temperature =
          "${(weatherData['temperature'] ?? 0).toStringAsFixed(1)}°C";
      humidity = "${weatherData['humidity'] ?? '--'}%";
      wind = "${weatherData['wind_speed'] ?? '--'} km/h";
      uvIndex = weatherData['uv']?.toString() ?? "--";
      aqi = aqiData['aqi']?.toString() ?? "--";

      weatherCondition = weatherData['condition'] ?? "Unknown";
      weatherIcon = weatherService.getWeatherIcon(weatherCondition);
      backgroundImage =
          weatherService.getBackgroundImage(weatherCondition);

      lastUpdated =
          DateFormat('hh:mm a').format(DateTime.now());

      isLoading = false;
    });
  } catch (e) {
    debugPrint("🔥 Home fetch error: $e");
    if (mounted) setState(() => isLoading = false);
  }
}


@override
Widget build(BuildContext context) {
  final bool locationReady = lat != 0.0 && lon != 0.0;
return Scaffold(
body: RefreshIndicator(
onRefresh: _fetchHomeData,
child: Stack(
children: [
Positioned.fill(
child: Image.asset(backgroundImage, fit: BoxFit.cover),
),
Container(color: Colors.black.withOpacity(0.30)),
SafeArea(
child: isLoading
? const Center(
child: CircularProgressIndicator(color: Colors.white),
)
: ListView(
padding: const EdgeInsets.all(16),
children: [
Text(
locationName,
textAlign: TextAlign.center,
style: const TextStyle(
color: Colors.white,
fontSize: 26,
fontWeight: FontWeight.bold),
),
const SizedBox(height: 4),
Text(
"Updated: $lastUpdated",
textAlign: TextAlign.center,
style: const TextStyle(color: Colors.white70, fontSize: 14),
),
const SizedBox(height: 20),


              // WEATHER CARD
              Card(
                color: Colors.white24,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      BoxedIcon(weatherIcon,
                          size: 64, color: Colors.white),
                      const SizedBox(height: 10),
                      Text(
                        temperature,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        weatherCondition.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 18),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _infoColumn("Humidity", humidity),
                          _infoColumn("Wind", wind),
                          _infoColumn("UV", uvIndex),
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
                          locationName: locationName,
                          selectedDay: DateTime.now(),
                          token: "public_token",
                        ),
                      ),
                    );
                  }),

                  _quickButton("Radar", Icons.map, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                RadarScreen(lat: lat, lon: lon)));
                  }),

                  _quickButton(
                    "Alerts",
                    Icons.warning,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AnomalyScreen(
                            lat: lat,
                            lon: lon,
                          ),
                        ),
                      );
                    },
                    enabled: locationReady,
                  ),



                  _quickButton("Panic", Icons.sos, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PanicScreen()));
                  }),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    ),
  ),
);


}

Widget _quickButton(
  String label,
  IconData icon,
  VoidCallback onTap, {
  bool enabled = true,
}) {
  return GestureDetector(
    onTap: enabled ? onTap : null,
    child: Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: enabled ? Colors.white24 : Colors.white12,
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
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
