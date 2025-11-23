import 'package:flutter/material.dart';

class FarmerCropHealth extends StatelessWidget {
  const FarmerCropHealth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Crop Health & Advisory",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // SOIL HEALTH
            _sectionTitle("Soil Health"),
            _healthCard(
              icon: Icons.terrain,
              title: "Moisture",
              value: "62%",
              subtitle: "Moderate moisture level",
              color: Colors.blue,
            ),
            _healthCard(
              icon: Icons.device_thermostat,
              title: "Soil Temperature",
              value: "24°C",
              subtitle: "Ideal for paddy growth",
              color: Colors.orange,
            ),
            _healthCard(
              icon: Icons.science,
              title: "NPK Levels",
              value: "N: Low | P: Medium | K: Good",
              subtitle: "Fertilizer required soon",
              color: Colors.purple,
            ),

            const SizedBox(height: 16),

            // WATERING STATUS
            _sectionTitle("Watering Status"),
            _healthCard(
              icon: Icons.water_drop,
              title: "Water Need",
              value: "Required in 4 hours",
              subtitle: "Best time: 5 PM - 7 PM",
              color: Colors.lightBlue,
            ),

            const SizedBox(height: 16),

            // PEST & DISEASE ALERT
            _sectionTitle("Pest & Disease Alert"),
            _healthCard(
              icon: Icons.bug_report,
              title: "Pest Risk",
              value: "Low",
              subtitle: "No major threats detected",
              color: Colors.red,
            ),
            _healthCard(
              icon: Icons.coronavirus,
              title: "Disease Probability",
              value: "12%",
              subtitle: "Safe conditions",
              color: Colors.deepOrange,
            ),

            const SizedBox(height: 16),

            // FERTILIZER RECOMMENDATION
            _sectionTitle("Fertilizer Recommendation"),
            _healthCard(
              icon: Icons.spa,
              title: "Suggested Fertilizer",
              value: "NPK 10-26-26",
              subtitle: "Apply within 2–3 days",
              color: Colors.green,
            ),

            const SizedBox(height: 16),

            // GROWTH STAGE
            _sectionTitle("Growth Stage"),
            _healthCard(
              icon: Icons.grass,
              title: "Current Stage",
              value: "Mid-growth",
              subtitle: "Healthy progress",
              color: Colors.teal,
            ),

            const SizedBox(height: 16),

            // AI SUGGESTION
            _sectionTitle("AI Suggestions"),
            _aiSuggestionBox(),
          ],
        ),
      ),
    );
  }

  // SECTION TITLE
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // INFO CARD
  Widget _healthCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // AI SUGGESTION BOX
  Widget _aiSuggestionBox() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "💡 Smart Tips",
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.green),
          ),
          SizedBox(height: 10),
          Text("• Rain expected tonight — avoid fertilizing."),
          Text("• Soil moisture is good — delay watering slightly."),
          Text("• Ideal spraying time: next morning."),
        ],
      ),
    );
  }
}
