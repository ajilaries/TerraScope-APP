import 'package:flutter/material.dart';

class TravelerQuickActions {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55, // Half screen
          minChildSize: 0.4,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Top drag handle
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 12),
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),

                const Text(
                  "Traveler Tools",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.all(16),
                    controller: scrollController,
                    crossAxisCount: 3,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    children: [
                      _actionTile(Icons.route, "Route\nWeather"),
                      _actionTile(Icons.security, "Safety\nInfo"),
                      _actionTile(Icons.backpack, "Packing\nAssistant"),
                      _actionTile(Icons.place, "Nearby\nPlaces"),
                      _actionTile(Icons.warning, "Emergency"),
                      _actionTile(Icons.tune, "Personalize"),
                      _actionTile(Icons.map, "Map\nMode"),
                    ],
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  // Custom tile
  static Widget _actionTile(IconData icon, String title) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, size: 35, color: Colors.blue),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        )
      ],
    );
  }
}
