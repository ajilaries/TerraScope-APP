import 'package:flutter/material.dart';

class TravelerSafteyCard extends StatelessWidget {
  final int travelSafteyScore;

  const TravelerSafteyCard({super.key, required this.travelSafteyScore});

  Color _safteyColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final safteyColor = _safteyColor(travelSafteyScore);
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "travel saftey",
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
                      color: safteyColor.withOpacity(0.12),
                    ),
                    child: Center(
                      child: Text(
                        "$travelSafteyScore",
                        style: TextStyle(
                          color: safteyColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      travelSafteyScore >= 80
                          ? "safe to travel"
                          : (travelSafteyScore >= 50
                                ? "take caution"
                                : "Avoid travel"),
                      style: TextStyle(fontSize: 16, color: safteyColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: travelSafteyScore / 100,
                color: safteyColor,
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
            child: const Center(
              child: Text(
                "Map preview \n(plug google maps here)",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
