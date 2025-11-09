import 'dart:ui';
import 'package:flutter/material.dart';
import '../Widgets/footer_buttons.dart';
import '../Screens/anomaly_screen.dart';
import '../Screens/settings_screen.dart';

class HomeScreen2 extends StatelessWidget {
  const HomeScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF0A0A0A),

      // ✅ AppBar Clean + Blur + Settings Navigation
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black.withOpacity(0.4),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.transparent),
          ),
        ),
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings, size: 26),
          )
        ],
      ),

      // ✅ Body + Footer
      body: Column(
        children: [
          Expanded(child: _buildMainFeatures(context)),
          const FooterButtons(),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  // ✅ Main Features Grid (Animated + Clean)
  Widget _buildMainFeatures(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1.05,
        ),
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return _featureCard(
                title: "Real-Time Weather",
                icon: Icons.cloud_outlined,
                gradient: const [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                onTap: () {},
              );
            case 1:
              return _featureCard(
                title: "Anomaly Alerts",
                icon: Icons.warning_amber_rounded,
                gradient: const [Color(0xFFFFA751), Color(0xFFFF5858)],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AnomalyScreen(),
                    ),
                  );
                },
              );
            case 2:
              return _featureCard(
                title: "Forecast",
                icon: Icons.calendar_today_outlined,
                gradient: const [Color(0xFF43E97B), Color(0xFF38F9D7)],
                onTap: () {},
              );
            case 3:
              return _featureCard(
                title: "History",
                icon: Icons.history,
                gradient: const [Color(0xFFFA8BFF), Color(0xFF2BD2FF)],
                onTap: () {},
              );
            default:
              return Container();
          }
        },
      ),
    );
  }

  // ✅ Improved Glass Card
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
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.07),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Stack(
          children: [
            // ✅ Glow effect
            Positioned(
              right: -40,
              bottom: -40,
              child: Container(
                height: 130,
                width: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: gradient.map((c) => c.withOpacity(0.4)).toList(),
                  ),
                ),
              ),
            ),

            // ✅ Center Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 46, color: Colors.white),
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
