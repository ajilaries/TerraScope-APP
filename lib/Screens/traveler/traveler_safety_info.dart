import 'package:flutter/material.dart';

class TravelerSafetyInfo extends StatelessWidget {
  const TravelerSafetyInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Travel Safety Information"),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Preparedness
            _buildSection(
              "Emergency Preparedness",
              [
                "Keep emergency contacts updated",
                "Save local emergency numbers",
                "Keep important documents in a safe place",
                "Have a communication plan with family",
                "Know your destination's emergency procedures",
              ],
              Icons.emergency,
              Colors.red,
            ),

            const SizedBox(height: 16),

            // Health & Medical
            _buildSection(
              "Health & Medical Safety",
              [
                "Get necessary vaccinations",
                "Carry prescription medications",
                "Have travel health insurance",
                "Know local medical facilities",
                "Stay hydrated, especially in hot climates",
                "Use sunscreen and insect repellent",
              ],
              Icons.medical_services,
              Colors.blue,
            ),

            const SizedBox(height: 16),

            // Weather Safety
            _buildSection(
              "Weather Safety",
              [
                "Check weather forecasts regularly",
                "Prepare for extreme weather conditions",
                "Have appropriate clothing and gear",
                "Know evacuation routes",
                "Stay informed about weather alerts",
                "Avoid risky activities during bad weather",
              ],
              Icons.wb_sunny,
              Colors.orange,
            ),

            const SizedBox(height: 16),

            // Personal Security
            _buildSection(
              "Personal Security",
              [
                "Stay aware of your surroundings",
                "Keep valuables secure",
                "Use reputable transportation",
                "Avoid walking alone at night",
                "Trust your instincts",
                "Share your location with trusted contacts",
              ],
              Icons.security,
              Colors.purple,
            ),

            const SizedBox(height: 16),

            // Transportation Safety
            _buildSection(
              "Transportation Safety",
              [
                "Use licensed taxis and rideshares",
                "Check vehicle safety features",
                "Wear seatbelts at all times",
                "Follow local traffic laws",
                "Plan routes in advance",
                "Have backup transportation options",
              ],
              Icons.directions_car,
              Colors.teal,
            ),

            const SizedBox(height: 16),

            // Digital Safety
            _buildSection(
              "Digital Safety",
              [
                "Use secure Wi-Fi networks",
                "Keep devices updated and protected",
                "Be cautious with personal information",
                "Use two-factor authentication",
                "Backup important data",
                "Monitor accounts for suspicious activity",
              ],
              Icons.phone_android,
              Colors.indigo,
            ),

            const SizedBox(height: 16),

            // Cultural Awareness
            _buildSection(
              "Cultural Awareness",
              [
                "Learn basic local phrases",
                "Respect local customs and traditions",
                "Dress appropriately for the culture",
                "Be mindful of photography etiquette",
                "Understand local laws and regulations",
                "Show respect for religious sites",
              ],
              Icons.public,
              Colors.brown,
            ),

            const SizedBox(height: 24),

            // Emergency Action Plan
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red, size: 28),
                        const SizedBox(width: 8),
                        const Text(
                          "Emergency Action Plan",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "If you find yourself in an emergency:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text("1. Stay calm and assess the situation"),
                    const Text("2. Move to a safe location if possible"),
                    const Text("3. Contact local emergency services"),
                    const Text("4. Notify your emergency contacts"),
                    const Text("5. Follow instructions from authorities"),
                    const Text("6. Keep communication lines open"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("• ", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                      Expanded(child: Text(item)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
