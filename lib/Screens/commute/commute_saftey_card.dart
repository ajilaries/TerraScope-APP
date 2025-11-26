import 'package:flutter/material.dart';

class CommuteSafetyCard extends StatelessWidget {
final int score;

const CommuteSafetyCard({super.key, required this.score});

Color _colorForScore(int s) {
if (s >= 80) return Colors.green;
if (s >= 60) return Colors.orange;
return Colors.red;
}

String _safetyLabel(int s) {
if (s >= 80) return "Very Safe";
if (s >= 60) return "Moderate";
return "Risky";
}

IconData _safetyIcon(int s) {
if (s >= 80) return Icons.verified_rounded;
if (s >= 60) return Icons.warning_amber_rounded;
return Icons.error_rounded;
}

@override
Widget build(BuildContext context) {
final color = _colorForScore(score);


return Container(
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.07),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ],
  ),
  
  child: Row(
    children: [
      CircleAvatar(
        radius: 28,
        backgroundColor: color.withOpacity(0.15),
        child: Icon(
          _safetyIcon(score),
          size: 32,
          color: color,
        ),
      ),

      const SizedBox(width: 16),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Commute Safety Score",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _safetyLabel(score),
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),

      Text(
        "$score/100",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    ],
  ),
);

}
}
