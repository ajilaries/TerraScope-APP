import 'package:flutter/material.dart';

class TravelerAlerts extends StatelessWidget {
  final List<Map<String, String>> routeAlerts;
  final VoidCallback? onViewAll;

  const TravelerAlerts({super.key, required this.routeAlerts, this.onViewAll});

  // ------------------------
  // STATIC METHOD FOR BOTTOM SHEET
  // ------------------------
  static void show(BuildContext context, List<Map<String, String>> alerts) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        expand: false,
        builder: (context, scrollCtrl) {
          return Container(
            padding: const EdgeInsets.all(12),
            child: ListView.separated(
              controller: scrollCtrl,
              itemCount: alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final a = alerts[idx];
                return ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red),
                  title: Text(a["title"] ?? ""),
                  subtitle: Text(a["desc"] ?? ""),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ------------------------
  // BUILD METHOD
  // ------------------------
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text("Route Alerts", style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text("View all"),
                  )
              ],
            ),
            const SizedBox(height: 8),
            ...routeAlerts.map((a) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.info_outline, color: Colors.orange),
                  title: Text(a["title"] ?? ""),
                  subtitle: Text(a["desc"] ?? ""),
                )),
            if (routeAlerts.isEmpty)
              const Text("No alerts on route"),
          ],
        ),
      ),
    );
  }
}
