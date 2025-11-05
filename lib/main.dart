import 'package:flutter/material.dart';
import 'package:terra_scope_apk/Screens/home_screen.dart';
import 'dart:async';

void main() {
  runApp(const TerraScopeApp());
}

class TerraScopeApp extends StatelessWidget {
  const TerraScopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
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
        'lib/assets/logo.png',
        height: 150,
      ),
      const SizedBox(height: 20),
      const Text(
        'TerraScope',
        style: TextStyle(
          color: Color.fromARGB(255, 17, 118, 121),
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    ],
  ),
),

    );
  }
}
