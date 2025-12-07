import 'package:flutter/material.dart';
import '../services/ai_predict_service.dart';

class AIPredictPage extends StatefulWidget {
  final double lat;
  final double lon;

  const AIPredictPage({super.key, required this.lat, required this.lon});

  @override
  State<AIPredictPage> createState() => _AIPredictPageState();
}

class _AIPredictPageState extends State<AIPredictPage> {
  late Future<List<Prediction>> _predictions;
  final service = AIPredictService(baseUrl: "http://10.0.2.2:8000");

  @override
  void initState() {
    super.initState();
    _predictions = service.getPredictions(widget.lat, widget.lon);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI Weather Predictions")),
      body: FutureBuilder<List<Prediction>>(
        future: _predictions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No predictions found."));
          } else {
            final predictions = snapshot.data!;
            return ListView.builder(
              itemCount: predictions.length,
              itemBuilder: (context, index) {
                final p = predictions[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(p.day),
                    subtitle: Text("Temp: ${p.temp}°C, Rain chance: ${p.rainChance}%"),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
