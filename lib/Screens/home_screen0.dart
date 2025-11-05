import 'package:flutter/material.dart';
import '../Services/weather_services.dart';
import '../Services/location_service.dart'; // <-- needed
//import 'package:intl/intl.dart';

class Home0 extends StatefulWidget {
  const Home0({super.key});

  @override
  State<Home0> createState() => _Home0State();
}

class _Home0State extends State<Home0> {
  List<Map<String, dynamic>> forecast = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchForecast(); // corrected method name
  }

  Future<void> fetchForecast() async {
    try {
      final locationData = await LocationService().getCurrentLocation();
      final lat = locationData['latitude'];
      final lon = locationData['longitude'];

      final realForecast = await WeatherService().getFiveDayForecast(lat, lon);

      setState(() {
        forecast = realForecast;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching forecast: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.3),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "5-Day Forecast",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Loading indicator
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: forecast.length,
                  itemBuilder: (context, index) {
                    final dayForecast = forecast[index];
                    return Container(
                      width: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(dayForecast["icon"], color: Colors.white, size: 32),
                          const SizedBox(height: 8),
                          Text("${dayForecast['temp']}°C",
                              style: const TextStyle(color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(dayForecast['day'],
                              style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
