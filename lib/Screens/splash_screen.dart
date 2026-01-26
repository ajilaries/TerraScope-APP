import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../Services/weather_services.dart';
import '../Services/nearby_cache_service.dart';
import '../Services/auth_service.dart';
import 'main_page.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Quick initialization - skip heavy preloading for snappy start
      // Initialize cache in background if needed, but don't wait
      NearbyCacheService.initializeCache().catchError((e) => print('Cache init error: $e'));

      // Schedule navigation after the current frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        // Always go to home screen - signup only required for mode screen
        const nextScreen = MainPage();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
        );

        // Load location and data in background after navigation
        _loadDataInBackground();
      });
    } catch (e) {
      print('Error during initialization: $e');
      // On error, still go to home screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      });
    }
  }

  Future<void> _loadDataInBackground() async {
    try {
      // Request location permission and get current position in background
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        print('Location fetched in background: ${position.latitude}, ${position.longitude}');

        // Load weather data in background
        final weatherData = await WeatherService.getCurrentWeather(
          position.latitude,
          position.longitude,
        );
        if (weatherData != null) {
          print('Weather data loaded in background: ${weatherData['weather'][0]['description']}');
        }
      }
    } catch (e) {
      print('Background loading error: $e');
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
