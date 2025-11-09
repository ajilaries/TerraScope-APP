import 'package:flutter/material.dart';
import '../Widgets/footer_buttons.dart';

class HomeScreen2 extends StatelessWidget {
  const HomeScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Terrascope",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Navigate to settings page
            },
            icon: const Icon(Icons.settings),
          ),
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

  Widget _buildMainFeatures(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        children: [
          _featureTile(
            title: "Real-Time Weather",
            icon: Icons.cloud,
            onTap: () {},
          ),
          _featureTile(
            title: "Anomaly Alerts",
            icon: Icons.warning_amber_rounded,
            onTap: () {},
          ),
          _featureTile(
            title: "Forecast",
            icon: Icons.calendar_today,
            onTap: () {},
          ),
          _featureTile(
            title: "History",
            icon: Icons.history,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _featureTile({
    required String title,
    required IconData icon,
    required Function onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
