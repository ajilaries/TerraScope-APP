import 'package:flutter/material.dart';

class TravelerAlerts {
  static void showAlerts(BuildContext context, List<Map<String, String>> alerts) {
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
}
