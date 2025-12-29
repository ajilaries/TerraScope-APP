import 'package:flutter/material.dart';
import '../../Services/location_service.dart';
import '../../Services/commute_service.dart';

class CommuteRoutePlanner extends StatefulWidget {
  final Function(double?, double?, String?)? onDestinationChanged;
  const CommuteRoutePlanner({super.key, this.onDestinationChanged});

  @override
  State<CommuteRoutePlanner> createState() => _CommuteRoutePlannerState();
}

class _CommuteRoutePlannerState extends State<CommuteRoutePlanner> {
  final TextEditingController fromCtrl =
      TextEditingController(text: "Current Location");
  final TextEditingController toCtrl =
      TextEditingController(text: "Office, Kochi");

  bool planning = false;
  String? eta;
  String? distance;

  Future<void> _planRoute() async {
    setState(() {
      planning = true;
      eta = null;
      distance = null;
    });

    // Get current location
    final pos = await LocationService.getCurrentPosition();
    if (pos == null) {
      setState(() {
        planning = false;
      });
      return;
    }

    // Get destination coordinates
    final destCoords =
        await LocationService.getCoordinatesFromAddress(toCtrl.text);
    if (destCoords == null || destCoords.isEmpty) {
      setState(() {
        planning = false;
      });
      return;
    }

    final dest = destCoords.first;
    final route = await CommuteService.getRoute(
        pos.latitude, pos.longitude, dest.latitude, dest.longitude);

    if (route != null) {
      final duration = route['duration'] as int;
      final dist = route['distance'] as double;
      setState(() {
        eta = "${(duration / 60).round()} mins";
        distance = "${(dist / 1000).toStringAsFixed(1)} km";
        planning = false;
      });
      // Notify parent about destination change
      widget.onDestinationChanged
          ?.call(dest.latitude, dest.longitude, toCtrl.text);
    } else {
      setState(() {
        planning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Commute Route Planner",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 14),

            // From Input
            TextField(
              controller: fromCtrl,
              decoration: const InputDecoration(
                labelText: "From",
                prefixIcon: Icon(Icons.my_location),
              ),
            ),
            const SizedBox(height: 10),

            // To Input
            TextField(
              controller: toCtrl,
              decoration: const InputDecoration(
                labelText: "To",
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: planning ? null : _planRoute,
                    icon: planning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.directions),
                    label: Text(planning ? "Planning..." : "Plan Route"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    final temp = fromCtrl.text;
                    fromCtrl.text = toCtrl.text;
                    toCtrl.text = temp;
                  },
                  child: const Icon(Icons.swap_horiz),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (eta != null && distance != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, size: 26),
                    const SizedBox(width: 10),
                    Text("ETA: $eta • Distance: $distance",
                        style: const TextStyle(fontSize: 15)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
