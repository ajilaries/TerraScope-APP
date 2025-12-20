import 'package:flutter/material.dart';
import 'package:terra_scope_apk/Screens/farmer/farmer_result_screen.dart';
import 'package:terra_scope_apk/popups/farmer_intro_popup.dart';
import 'package:terra_scope_apk/Screens/traveler/traveler_dashboard.dart';
import 'package:terra_scope_apk/Screens/commute/commute_dashboard.dart';
import 'Saftey/saftey_mode_screen.dart';

class HomeScreen0 extends StatefulWidget {
  final Function(String) onModeSelected;

  const HomeScreen0({super.key, required this.onModeSelected});

  @override
  State<HomeScreen0> createState() => _HomeScreen0State();
}

class _HomeScreen0State extends State<HomeScreen0> {
  String selectedMode = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Terrascope",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Your Weather. Your Safety.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                "Choose Your Experience",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  modeCard(
                    title: "Default",
                    icon: Icons.dashboard,
                    color: Colors.blue,
                    mode: "default",
                  ),
                  modeCard(
                    title: "Traveller",
                    icon: Icons.travel_explore,
                    color: Colors.green,
                    mode: "traveller",
                  ),
                  modeCard(
                    title: "Farmer",
                    icon: Icons.agriculture,
                    color: Colors.brown,
                    mode: "farmer",
                  ),
                  modeCard(
                    title: "Safety",
                    icon: Icons.shield,
                    color: Colors.red,
                    mode: "safety",
                  ),
                  modeCard(
                    title: "Kids / Senior",
                    icon: Icons.family_restroom,
                    color: Colors.deepPurple,
                    mode: "care",
                  ),
                  modeCard(
                    title: "Commute",
                    icon: Icons.commute,
                    color: Colors.blue,
                    mode: "commute",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // MODE CARD
  Widget modeCard({
    required String title,
    required IconData icon,
    required Color color,
    required String mode,
  }) {
    final bool isSelected = selectedMode == mode;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMode = mode;
        });

        if (mode == "farmer") {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => FarmerIntroPopup(
              onSubmit: (double lat, double lon, String soilType) {
                Navigator.pop(context); // close popup

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FarmerResultScreen(
                      lat: lat,
                      lon: lon,
                      soilType: soilType,
                    ),
                  ),
                );
              },
            ),
          );
        } 
        else if (mode == "traveller") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TravelerDashboard()),
          );
        } 
        else if (mode == "commute") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CommuteDashboard()),
          );
        }
        else if (mode == "safety") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SafetyModeScreen()),
          );
        } 
        else {
          widget.onModeSelected(mode);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
