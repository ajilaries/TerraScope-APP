import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../Services/weather_services.dart';
import '../Services/nearby_cache_service.dart';
import 'main_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize nearby services cache
      await NearbyCacheService.initializeCache();

      // Request location permission and get current position
      LocationPermission permission = await Geolocator.requestPermission();
      Position? position;
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Handle permission denied, but still proceed
        print('Location permission denied');
      } else {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        print('Location fetched: ${position.latitude}, ${position.longitude}');

        // Load weather data using the fetched location
        if (position != null) {
          final weatherData = await WeatherService.getCurrentWeather(
            position.latitude,
            position.longitude,
          );
          if (weatherData != null) {
            print(
                'Weather data loaded: ${weatherData['weather'][0]['description']}');
          }

          // Preload nearby services data for instant access
          await NearbyCacheService.preloadNearbyServices(
            position.latitude,
            position.longitude,
          );
        }
      }

      // Navigate to main page after initialization
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } catch (e) {
      print('Error during initialization: $e');
      // Still navigate even if there's an error
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/terrascope-512.png',
              height: MediaQuery.of(context).size.height *
                  0.2, // 20% of screen height
              width: MediaQuery.of(context).size.width *
                  0.4, // 40% of screen width
            ),
            const SizedBox(height: 20),
            const Text(
              "TERRASCOPE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.15,
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey, // Dark outer circle
      ),
      child: Center(
        child: Container(
          width: 120,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.black, // Dark inner rounded rectangle
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Center(
            child: Icon(
              Icons.public, // Globe icon to represent "terra"
              color: Colors.white,
              size: 50,
            ),
          ),
        ),
      ),
    );
  }
}
