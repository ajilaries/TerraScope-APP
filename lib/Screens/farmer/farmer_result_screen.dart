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
      appBar: AppBar(title: const Text("Farmer Insights")),
      body: FutureBuilder(
        future: prediction,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong 😵"));
          }

          final data = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "🌾 Best Crop: ${data.crop}",
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                Text("⚠️ Risk Level: ${data.risk}"),
                Text("🌡️ Temperature: ${data.temperature} °C"),
                Text("🌧️ Rainfall: ${data.rainfall} mm"),

                const SizedBox(height: 10),

                Text(
                  "📌 ${data.suggestion}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
