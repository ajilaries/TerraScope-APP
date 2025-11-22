import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'home_screen2.dart';
import 'home_screen0.dart';
import '../Screens/farmer/farmer_dashboard.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView(
      scrollDirection: Axis.horizontal,
      children: [
        HomeScreen0(
          onModeSelected: (mode) {
            print("Selected mode: $mode");

            if (mode == "farmer") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FarmerDashboard(),
                ),
              );
            }
          },
        ),

        // Your existing screens
        MainHomeScreen(),
        HomeScreen2(),
      ],
    );
  }
}
