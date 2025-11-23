import 'package:flutter/material.dart';

class CropRecommendationScreen extends StatelessWidget {
  const CropRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: const Text(
          "Crop Recommendations",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Based on today’s weather & soil conditions",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 20),

            // Crop Cards
            _cropCard(
              crop: "Paddy",
              suitability: 88,
              soil: "Clay / Loam Soil",
              temp: "20°C - 35°C",
              icon: Icons.grass,
              reason:
                  "High rainfall chances and good humidity make it ideal for paddy growth today.",
            ),

            const SizedBox(height: 16),

            _cropCard(
              crop: "Pepper",
              suitability: 75,
              soil: "Loamy Soil",
              temp: "23°C - 32°C",
              icon: Icons.eco,
              reason:
                  "Cloudy weather with moderate moisture supports pepper plant growth.",
            ),

            const SizedBox(height: 16),

            _cropCard(
              crop: "Coconut",
              suitability: 82,
              soil: "Sandy Loam Soil",
              temp: "25°C - 35°C",
              icon: Icons.dark_mode,
              reason:
                  "Warm temperature and humidity are favorable for coconut trees.",
            ),
          ],
        ),
      ),
    );
  }

  // ===============================
  // Crop Card Widget
  // ===============================
  Widget _cropCard({
    required String crop,
    required int suitability,
    required String soil,
    required String temp,
    required IconData icon,
    required String reason,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.green.shade100,
                child: Icon(icon, color: Colors.green, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  crop,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "$suitability%",
                style: const TextStyle(
                    color: Colors.green,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text("• Ideal Soil: $soil",
              style: const TextStyle(fontSize: 15, color: Colors.black87)),

          Text("• Temperature: $temp",
              style: const TextStyle(fontSize: 15, color: Colors.black87)),

          const SizedBox(height: 16),

          // Why recommended section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.green, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    reason,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
