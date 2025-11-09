import 'package:flutter/material.dart';
import '../Widgets/footer_buttons.dart';
import '../Screens/anomaly_screen.dart';

class HomeScreen2 extends StatelessWidget {
  const HomeScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF0A0A0A),

      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.6),
        elevation: 0,
        title: const Text(
          "Terrascope",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings, size: 26),
          )
        ],
      ),

      body: Column(
        children: [
          Expanded(child: _buildMainFeatures(context)),
          const FooterButtons(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ✅ Main Features Grid
  Widget _buildMainFeatures(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: GridView(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1.05,
        ),
        children: [
          _featureCard(
            title: "Real-Time Weather",
            icon: Icons.cloud_outlined,
            gradient: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
            onTap: () {},
          ),
          _featureCard(
            title: "Anomaly Alerts",
            icon: Icons.warning_amber_rounded,
            gradient: [Color(0xFFFFA751), Color(0xFFFF5858)],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AnomalyScreen()),
              );
          },
          ),


          _featureCard(
            title: "Forecast",
            icon: Icons.calendar_today_outlined,
            gradient: [Color(0xFF43E97B), Color(0xFF38F9D7)],
            onTap: () {},
          ),
          _featureCard(
            title: "History",
            icon: Icons.history,
            gradient: [Color(0xFFFA8BFF), Color(0xFF2BD2FF)],
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ✅ Glassmorphic Card Widget
  Widget _featureCard({
    required String title,
    required IconData icon,
    required List<Color> gradient,
    required Function onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Stack(
          children: [
            // ✅ Fancy Gradient Glow Corner
            Positioned(
              right: -40,
              bottom: -40,
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: gradient.map((c) => c.withOpacity(0.35)).toList(),
                  ),
                ),
              ),
            ),

            // ✅ Content Area
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 45, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
