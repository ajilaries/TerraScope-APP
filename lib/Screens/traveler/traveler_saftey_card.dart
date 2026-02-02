import 'package:flutter/material.dart';
import 'travel_map_preview.dart';
import 'package:latlong2/latlong.dart';

class TravelerSafetyCard extends StatelessWidget {
  final int score;
  final double? latitude;
  final double? longitude;

  const TravelerSafetyCard({
    super.key,
    required this.score,
    this.latitude,
    this.longitude,
  });

  Color _safetyColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final color = _safetyColor(score);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Travel Safety",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withOpacity(0.12),
                        ),
                        child: Center(
                          child: Text(
                            "$score",
                            style: TextStyle(
                              color: color,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          score >= 80
                              ? "Safe to travel"
                              : (score >= 50 ? "Take caution" : "Avoid travel"),
                          style: TextStyle(fontSize: 16, color: color),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: score / 100,
                    color: color,
                    backgroundColor: Colors.grey.shade300,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: latitude != null && longitude != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: TravelMapPreview(
                          location: LatLng(latitude!, longitude!),
                        ),
                      )
                    : const Center(
                        child: Text(
                          "Map preview\n(Location unavailable)",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
