import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../Services/location_service.dart';
import '../../Services/weather_services.dart';
import '../../Services/nearby_services.dart';
import '../../Services/emergency_contact_service.dart';
import '../../models/emergency_contact.dart';
import '../../popups/personalization_popup.dart';
import 'traveler_sos_screen.dart';
import 'traveler_nearby_services_screen.dart';
import 'traveler_packing_assistant.dart';
import 'traveler_safety_info.dart';
import 'travel_map_preview.dart';

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
                    crossAxisCount: 3,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    children: [
                      _actionTile(Icons.route, "Route\nWeather", () => _showRouteWeather(context)),
                      _actionTile(Icons.security, "Safety\nInfo", () => _showSafetyInfo(context)),
                      _actionTile(Icons.backpack, "Packing\nAssistant", () => _showPackingAssistant(context)),
                      _actionTile(Icons.place, "Nearby\nPlaces", () => _showNearbyPlaces(context)),
                      _actionTile(Icons.warning, "Emergency", () => _showEmergency(context)),
                      _actionTile(Icons.tune, "Personalize", () => _showPersonalize(context)),
                      _actionTile(Icons.map, "Map\nMode", () => _showMapMode(context)),
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

  // Custom tile with onTap functionality
  static Widget _actionTile(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 32, color: Colors.blue),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }

  static void _showRouteWeather(BuildContext context) async {
    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos != null) {
        final forecast = await WeatherService.getWeatherForecastCached(pos.latitude, pos.longitude);

        if (forecast != null && forecast['list'] != null) {
          final hourlyData = (forecast['list'] as List).take(24).map((item) {
            final parsed = WeatherService.parseWeatherData(item);
            final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
            return {
              'time': '${dt.hour.toString().padLeft(2, '0')}:00',
              'temp': '${parsed['temperature'].toStringAsFixed(1)}°C',
              'weather': parsed['description'],
              'wind': '${parsed['windSpeed']} km/h',
              'rain': '${parsed['rainMm']} mm',
            };
          }).toList();

          Navigator.pop(context); // Close the bottom sheet

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("24-Hour Weather Forecast"),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: ListView.builder(
                  itemCount: hourlyData.length,
                  itemBuilder: (context, index) {
                    final data = hourlyData[index];
                    return ListTile(
                      title: Text("${data['time']} - ${data['temp']}"),
                      subtitle: Text("${data['weather']} | Wind: ${data['wind']} | Rain: ${data['rain']}"),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      Navigator.pop(context); // Close the bottom sheet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading weather: $e")),
      );
    }
  }

  static void _showSafetyInfo(BuildContext context) {
    Navigator.pop(context); // Close the bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TravelerSafetyInfo()),
    );
  }

  static void _showPackingAssistant(BuildContext context) {
    Navigator.pop(context); // Close the bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TravelerPackingAssistant()),
    );
  }

  static void _showNearbyPlaces(BuildContext context) async {
    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos != null) {
        Navigator.pop(context); // Close the bottom sheet

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TravelerNearbyServicesScreen(
              latitude: pos.latitude,
              longitude: pos.longitude,
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close the bottom sheet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error getting location")),
      );
    }
  }

  static void _showEmergency(BuildContext context) {
    Navigator.pop(context); // Close the bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TravelerSOSScreen()),
    );
  }

  static void _showPersonalize(BuildContext context) {
    Navigator.pop(context); // Close the bottom sheet
    showPersonalizationPopup(context);
  }

  static void _showMapMode(BuildContext context) async {
    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos != null) {
        Navigator.pop(context); // Close the bottom sheet

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Map Mode"),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: TravelMapPreview(location: LatLng(pos.latitude, pos.longitude)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: $e")),
      );
      Navigator.pop(context); // Close the bottom sheet
    }
  }
}
