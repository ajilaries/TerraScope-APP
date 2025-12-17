import 'package:flutter/material.dart';
import 'farmer_prediction.dart';
import '/Services/farmer_api_service.dart';

class FarmerResultScreen extends StatefulWidget {
  final double lat;
  final double lon;
  final String soilType;

  const FarmerResultScreen({
    super.key,
    required this.lat,
    required this.lon,
    required this.soilType,
  });

  @override
  State<FarmerResultScreen> createState() => _FarmerResultScreenState();
}

class _FarmerResultScreenState extends State<FarmerResultScreen> {
  late Future<FarmerPrediction> prediction;

  @override
  void initState() {
    super.initState();
    prediction = FarmerApiService.getPrediction(
      lat: widget.lat,
      lon: widget.lon,
      soilType: widget.soilType,
    ).then((data) => FarmerPrediction.fromJson(data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Farmer Insights 🌾")),
      body: FutureBuilder<FarmerPrediction>(
        future: prediction,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error} 😵"),
            );
          }

          final data = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "📅 Best Planting Month: ${data.bestPlantingMonth}",
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 8),

                Text("🌾 Expected Yield: ${data.expectedYield.toStringAsFixed(2)} kg"),
                Text("⚠️ Risk Level: ${data.yieldRisk}"),

                const SizedBox(height: 16),

                Text(
                  "📊 Month-wise Yield",
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                ...data.monthWiseYield.entries.map(
                  (e) => Text("Month ${e.key}: ${e.value.toStringAsFixed(1)} kg"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
