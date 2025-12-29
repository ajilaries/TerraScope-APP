import 'package:flutter/material.dart';
import '../../Services/commute_service.dart';
import '../../Services/location_service.dart';

class CommuteQuickActions {
  static Future<void> show(BuildContext context, double? destLat,
      double? destLon, String? destAddress) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Commute Tools",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Metro Timings
              _actionTile(
                icon: Icons.subway,
                title: "Metro Timings",
                subtitle: "Next train & route schedule",
                onTap: () {
                  Navigator.pop(context);
                  _showRealMetroTimings(context, destLat, destLon, destAddress);
                },
              ),
              const SizedBox(height: 10),

              // Bus Status
              _actionTile(
                icon: Icons.directions_bus,
                title: "Bus Status",
                subtitle: "Live bus arrival & delays",
                onTap: () {
                  Navigator.pop(context);
                  _showRealBusStatus(context, destLat, destLon, destAddress);
                },
              ),
              const SizedBox(height: 10),

              // Cab Fare Estimate
              _actionTile(
                icon: Icons.local_taxi,
                title: "Cab Fare Estimate",
                subtitle: "Auto/Taxi/OLA/UBER approx fare",
                onTap: () {
                  Navigator.pop(context);
                  _showRealCabFare(context, destLat, destLon, destAddress);
                },
              ),
              const SizedBox(height: 10),

              // Traffic Report
              _actionTile(
                icon: Icons.traffic,
                title: "Traffic Density",
                subtitle: "Slow / Moderate / Heavy traffic",
                onTap: () {
                  Navigator.pop(context);
                  _showRealTrafficDensity(
                      context, destLat, destLon, destAddress);
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  static Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.indigo.shade50,
            child: Icon(icon, color: Colors.indigo.shade700, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  static void _showRealMetroTimings(BuildContext context, double? destLat,
      double? destLon, String? destAddress) async {
    // Use destination coordinates if available, otherwise current location
    final lat =
        destLat ?? (await LocationService.getCurrentPosition())?.latitude;
    final lon =
        destLon ?? (await LocationService.getCurrentPosition())?.longitude;

    if (lat != null && lon != null) {
      final data = await CommuteService.getMetroTimings(lat, lon);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
              "Metro Timings ${destAddress != null ? 'to $destAddress' : 'at Current Location'}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: data.containsKey('nextTrainAluva')
                ? [
                    Text("Next train to Aluva: ${data['nextTrainAluva']}"),
                    Text(
                        "Next train to Fort Kochi: ${data['nextTrainFortKochi']}"),
                    Text("Frequency: ${data['frequency']}"),
                  ]
                : [
                    Text(data['nextTrain'] ?? 'No metro service available'),
                  ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  static void _showRealBusStatus(BuildContext context, double? destLat,
      double? destLon, String? destAddress) async {
    // Use destination coordinates if available, otherwise current location
    final lat =
        destLat ?? (await LocationService.getCurrentPosition())?.latitude;
    final lon =
        destLon ?? (await LocationService.getCurrentPosition())?.longitude;

    if (lat != null && lon != null) {
      final data = await CommuteService.getBusStatus(lat, lon);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
              "Bus Status ${destAddress != null ? 'to $destAddress' : 'at Current Location'}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: data.containsKey('bus15C')
                ? [
                    Text("Location: ${data['location']}"),
                    Text("Bus 15C: ${data['bus15C']}"),
                    Text("Bus 12A: ${data['bus12A']}"),
                    Text("Bus 8B: ${data['bus8B']}"),
                  ]
                : [
                    Text(data['status'] ?? 'No bus data available'),
                    if (data.containsKey('location'))
                      Text("Location: ${data['location']}"),
                    if (data.containsKey('nextBus'))
                      Text("Next bus: ${data['nextBus']}"),
                  ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  static void _showRealCabFare(BuildContext context, double? destLat,
      double? destLon, String? destAddress) async {
    final pos = await LocationService.getCurrentPosition();
    if (pos != null) {
      // Use destination coordinates if available, otherwise assume 5km away
      final finalDestLat = destLat ?? pos.latitude + 0.045; // approx 5km
      final finalDestLon = destLon ?? pos.longitude + 0.045;
      final data = await CommuteService.getCabFareEstimate(
          pos.latitude, pos.longitude, finalDestLat, finalDestLon);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
              "Cab Fare Estimate ${destAddress != null ? 'to $destAddress' : 'for 5km trip'}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Auto Rickshaw: ${data['autoRickshaw']}"),
              Text("Uber/Ola Mini: ${data['uberOlaMini']}"),
              Text("Uber/Ola Sedan: ${data['uberOlaSedan']}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  static void _showRealTrafficDensity(BuildContext context, double? destLat,
      double? destLon, String? destAddress) async {
    // Use destination coordinates if available, otherwise current location
    final lat =
        destLat ?? (await LocationService.getCurrentPosition())?.latitude;
    final lon =
        destLon ?? (await LocationService.getCurrentPosition())?.longitude;

    if (lat != null && lon != null) {
      final data = await CommuteService.getTrafficDensity(lat, lon);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
              "Traffic Density ${destAddress != null ? 'to $destAddress' : 'at Current Location'}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Current Traffic: ${data['density']}"),
              Text("Current Speed: ${data['currentSpeed']}"),
              Text("Free Flow Speed: ${data['freeFlowSpeed']}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }
}
