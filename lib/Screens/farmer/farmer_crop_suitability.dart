import 'package:flutter/material.dart';

class FarmerCropSuitability extends StatelessWidget {
  const FarmerCropSuitability({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "crop suitability",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
      ),
      body: Container(
        color: Colors.brown.shade50,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _cropCard(
              context,
              cropName: "Paddy",
              suitability: 82,
              description:
                  "Ideal conditions. Current temperature and rainfall fit perfectly for paddy growth.",
            ),
            const SizedBox(height: 16),

            _cropCard(
              context,
              cropName: "Pepper",
              suitability: 67,
              description:
                  "Moderate suitability. High humidity is good, but rainfall is slightly low.",
            ),
            const SizedBox(height: 16),

            _cropCard(
              context,
              cropName: "Coconut",
              suitability: 74,
              description:
                  "Good conditions. Warm climate and mild winds support healthy coconut tree growth.",
            ),
          ],
        ),
      ),
    );
  }
  Widget _cropCard(
    BuildContext context, {
    required String cropName,
    required int suitability,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crop Name
          Text(
            cropName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 12),

          // Suitability Progress Bar + Percentage
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: suitability / 100,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation(
                      suitability > 70
                          ? Colors.green
                          : suitability > 40
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "$suitability%",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Description
          Text(
            description,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

}
