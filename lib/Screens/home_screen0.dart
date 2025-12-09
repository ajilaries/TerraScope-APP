import 'package:flutter/material.dart';
import 'package:terra_scope_apk/popups/farmer_intro_popup.dart';
import 'package:terra_scope_apk/Screens/signup_screen.dart';
// <--- import your signup page

class HomeScreen0 extends StatefulWidget {
  final Function(String) onModeSelected;

  const HomeScreen0({super.key, required this.onModeSelected});

  @override
  State<HomeScreen0> createState() => _HomeScreen0State();
}

class _HomeScreen0State extends State<HomeScreen0> {
  String selectedMode = ""; // stores selected mode

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
                  Text(
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
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SECTION TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Choose Your Experience",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 20),

            // MODES GRID
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
                    title: "commute",
                    icon:Icons.commute,
                    color: Colors.blue,
                    mode:"commute",
                  )
                ],
              ),
            ),

            const SizedBox(height: 10),

            Center(
              child: Text(
                "Switching modes requires login",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ),

            const SizedBox(height: 20),

            // LOGIN BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedMode.isEmpty
                      ? Colors.grey
                      : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: selectedMode.isEmpty
                    ? null
                    : () {
                        if (selectedMode == "default") {
                          widget.onModeSelected(selectedMode);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SignupScreen(selectedMode: selectedMode),
                            ),
                          );
                        }
                      },
                child: Text(
                  "Continue",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // MODE CARD UI
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

        // Show intro popup for special modes
        if (mode == "farmer") {
          showFarmerIntroPopup(context);
        }
        //  else if (mode == "traveller") {
        // //   showTravellerIntroPopup(context);
        //  } else if (mode == "safety") {
        // //   showSafetyIntroPopup(context);
        //  } else if (mode == "care") {
        // //   showCareIntroPopup(context);
        // // }
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
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 3),
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
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
