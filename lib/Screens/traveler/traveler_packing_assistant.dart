import 'package:flutter/material.dart';

class TravelerPackingAssistant extends StatelessWidget {
  const TravelerPackingAssistant({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Packing Assistant"),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Smart Packing Recommendations",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Based on your destination's weather and activities, here's what you should pack:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Essential Items
            _buildCategory(
              "Essential Items",
              [
                "Passport/ID documents",
                "Travel insurance documents",
                "Credit/debit cards and cash",
                "Phone charger and adapters",
                "Medications and prescriptions",
              ],
              Icons.assignment,
              Colors.blue,
            ),

            const SizedBox(height: 16),

            // Clothing
            _buildCategory(
              "Clothing",
              [
                "Weather-appropriate clothing",
                "Comfortable walking shoes",
                "Light jacket or sweater",
                "Underwear and socks",
                "Sleepwear",
              ],
              Icons.checkroom,
              Colors.purple,
            ),

            const SizedBox(height: 16),

            // Toiletries
            _buildCategory(
              "Toiletries",
              [
                "Toothbrush and toothpaste",
                "Shampoo and body wash",
                "Deodorant",
                "Skincare products",
                "Makeup and hair products",
              ],
              Icons.cleaning_services,
              Colors.teal,
            ),

            const SizedBox(height: 16),

            // Electronics
            _buildCategory(
              "Electronics",
              [
                "Smartphone and charger",
                "Power bank",
                "Headphones",
                "Camera (optional)",
                "Travel pillow (for flights)",
              ],
              Icons.devices,
              Colors.orange,
            ),

            const SizedBox(height: 24),

            // Tips
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Text(
                          "Packing Tips",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text("• Pack versatile clothing that can be mixed and matched"),
                    const Text("• Choose travel-sized toiletries to save space"),
                    const Text("• Make copies of important documents"),
                    const Text("• Pack snacks for the journey"),
                    const Text("• Leave room for souvenirs on the way back"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String title, List<String> items, IconData icon, Color color) {
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
