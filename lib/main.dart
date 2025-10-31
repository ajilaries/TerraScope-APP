import 'package:flutter/material.dart';
import 'package:terra_scope_apk/Screens/home_screen.dart';

void main() {
  runApp(const TerraScopeApp());
}

class TerraScopeApp extends StatelessWidget {
  const TerraScopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'terra scope',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,scaffoldBackgroundColor: Colors.blueGrey.shade100,

      ),
      home: const HomeScreen(),
    );
  }
}
