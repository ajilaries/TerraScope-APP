import 'package:flutter/material.dart';

class CommuteWeatherMini extends StatelessWidget {
  final String place;
  final double temp;
  final int aqi;

  const CommuteWeatherMini({
    super.key,
    required this.place,
    required this.temp,
    required this.aqi,
  });

  Color _aqiColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.orange;
    if (aqi <= 150) return Colors.red;
    return Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Weather
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Temp: ${temp.toStringAsFixed(0)}°C",
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "AQI: $aqi",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _aqiColor(aqi),
                    ),
                  ),
                ],
              ),
            ),

            // Rounded weather indicator
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.indigo.shade50,
              child: Text(
                "${temp.toStringAsFixed(0)}°",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
