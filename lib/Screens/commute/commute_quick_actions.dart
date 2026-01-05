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
              const SizedBox(height: 10),
              _actionTile(
                icon: Icons.subway,
                title: "Nearest Metro",
                subtitle: "Find closest metro station",
                onTap: () {
                  Navigator.pop(context);
                  _showNearestMetro(context);
                },
              ),
              const SizedBox(height: 10),
              _actionTile(
                icon: Icons.directions_bus,
                title: "Nearest Bus Stop",
                subtitle: "Find closest bus stop",
                onTap: () {
                  Navigator.pop(context);
                  _showNearestBusStop(context);
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

  // ===================== METRO =====================
  static void _showRealMetroTimings(BuildContext context, double? destLat,
      double? destLon, String? destAddress) async {
    final pos = await LocationService.getCurrentPosition();
    if (pos == null) return;

    final data = await CommuteService.getMetroTimings(
      pos.latitude,
      pos.longitude,
      destLat ?? pos.latitude,
      destLon ?? pos.longitude,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            "Metro Timings ${destAddress != null ? 'to $destAddress' : ''}"),
        content: data.isNotEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: data.entries
                    .map((e) => Text("${e.key}: ${e.value}"))
                    .toList(),
              )
            : const Text("No metro service available"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
        ],
      ),
    );
  }

  // ===================== BUS =====================
  static void _showRealBusStatus(BuildContext context, double? destLat,
      double? destLon, String? destAddress) async {
    final pos = await LocationService.getCurrentPosition();
    if (pos == null) return;

    final data = await CommuteService.getBusStatus(
      pos.latitude,
      pos.longitude,
      destLat ?? pos.latitude,
      destLon ?? pos.longitude,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:
            Text("Bus Status ${destAddress != null ? 'to $destAddress' : ''}"),
        content: data.isNotEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: data.entries
                    .map((e) => Text("${e.key}: ${e.value}"))
                    .toList(),
              )
            : const Text("No bus service available"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
        ],
      ),
    );
  }

  // ===================== CAB =====================
  static void _showRealCabFare(BuildContext context, double? destLat,
      double? destLon, String? destAddress) async {
    final pos = await LocationService.getCurrentPosition();
    if (pos == null) return;

    final data = await CommuteService.getCabFareEstimate(
      pos.latitude,
      pos.longitude,
      destLat ?? pos.latitude + 0.05,
      destLon ?? pos.longitude + 0.05,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            "Cab Fare Estimate ${destAddress != null ? 'to $destAddress' : ''}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              data.entries.map((e) => Text("${e.key}: ${e.value}")).toList(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
        ],
      ),
    );
  }

  // ===================== TRAFFIC =====================
  static void _showRealTrafficDensity(BuildContext context, double? destLat,
      double? destLon, String? destAddress) async {
    final pos = await LocationService.getCurrentPosition();
    if (pos == null) return;

    final data = await CommuteService.getTrafficDensity(
      pos.latitude,
      pos.longitude,
      destLat ?? pos.latitude + 0.05,
      destLon ?? pos.longitude + 0.05,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            "Traffic Density ${destAddress != null ? 'to $destAddress' : ''}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              data.entries.map((e) => Text("${e.key}: ${e.value}")).toList(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
        ],
      ),
    );
  }

  // ===================== NEAREST METRO =====================
  static void _showNearestMetro(BuildContext context) async {
    final pos = await LocationService.getCurrentPosition();
    if (pos == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Unable to get current location"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
          ],
        ),
      );
      return;
    }

    final nearestMetro =
        await CommuteService.getNearestMetro(pos.latitude, pos.longitude);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Nearest Metro Station"),
        content: nearestMetro != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Name: ${nearestMetro['name']}"),
                  const SizedBox(height: 8),
                  Text("Lat: ${nearestMetro['lat']}"),
                  Text("Lon: ${nearestMetro['lon']}"),
                ],
              )
            : const Text("No metro station found nearby"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
        ],
      ),
    );
  }

  // ===================== NEAREST BUS STOP =====================
  static void _showNearestBusStop(BuildContext context) async {
    final pos = await LocationService.getCurrentPosition();
    if (pos == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Unable to get current location"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
          ],
        ),
      );
      return;
    }

    final nearestBus =
        await CommuteService.getNearestBusStop(pos.latitude, pos.longitude);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Nearest Bus Stop"),
        content: nearestBus != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Name: ${nearestBus['name']}"),
                  const SizedBox(height: 8),
                  Text("Lat: ${nearestBus['lat']}"),
                  Text("Lon: ${nearestBus['lon']}"),
                ],
              )
            : const Text("No bus stop found nearby"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
        ],
      ),
    );
  }
}
