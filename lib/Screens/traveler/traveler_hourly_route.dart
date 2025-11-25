import 'package:flutter/material.dart';

class TravelerHourlyRoute extends StatelessWidget {
  final List<Map<String, String>> hourlyRoute;

  const TravelerHourlyRoute({super.key, required this.hourlyRoute});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hourlyRoute.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final h = hourlyRoute[idx];
          return Container(
            width: 120,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(h["hour"] ?? ""),
                const SizedBox(height: 6),
                Text(h["weather"] ?? "", style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 6),
                Text(h["temp"] ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }
}
