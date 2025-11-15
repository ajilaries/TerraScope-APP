import 'package:flutter/material.dart';

class HomeScreen0 extends StatelessWidget {
  final Function(String) onModeSelected;

  const HomeScreen0({super.key, required this.onModeSelected});

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
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // MODES SECTION TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Choose Your Experience",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // GRID OF MODES
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  modeCard(
                    context,
                    title: "Default",
                    icon: Icons.dashboard,
                    color: Colors.blue,
                    mode: "default",
                  ),
                  modeCard(
                    context,
                    title: "Traveller",
                    icon: Icons.travel_explore,
                    color: Colors.green,
                    mode: "traveller",
                  ),
                  modeCard(
                    context,
                    title: "Farmer",
                    icon: Icons.agriculture,
                    color: Colors.brown,
                    mode: "farmer",
                  ),
                  modeCard(
                    context,
                    title: "Safety",
                    icon: Icons.shield,
                    color: Colors.red,
                    mode: "safety",
                  ),
                  modeCard(
                    context,
                    title: "Kids / Senior",
                    icon: Icons.family_restroom,
                    color: Colors.deepPurple,
                    mode: "care",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // LOGIN REQUIRED NOTE
            Center(
              child: Text(
                "Switching modes requires login",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // LOGIN BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Login / Continue",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // 🔥 MODE CARD WIDGET
  Widget modeCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String mode,
  }) {
    return GestureDetector(
      onTap: () {
        onModeSelected(mode);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
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
            )
          ],
        ),
      ),
    );
  }
}
