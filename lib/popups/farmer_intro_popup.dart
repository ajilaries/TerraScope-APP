import 'package:flutter/material.dart';
import 'package:terra_scope_apk/Services/location_service.dart';
import 'package:terra_scope_apk/Services/soil_service.dart';
import 'package:terra_scope_apk/Screens/farmer/farmer_dashboard.dart';

class FarmerIntroPopup extends StatelessWidget {
  final void Function(double lat, double lon, String soilType) onSubmit;

  const FarmerIntroPopup({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ICON
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                Icons.agriculture,
                color: Colors.green.shade700,
                size: 70,
              ),
            ),

            const SizedBox(height: 20),

            // TITLE
            Text(
              "Welcome to Farmer Mode",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),

            const SizedBox(height: 12),

            // DESCRIPTION
            Text(
              "Smart farming powered by weather data, AI predictions, and real-time alerts — personalized for your land.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),

            const SizedBox(height: 18),

            // FEATURES
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FeatureItem("Auto crop detection using location"),
                  _FeatureItem("AI-based crop & yield prediction"),
                  _FeatureItem("Weather + soil risk analysis"),
                  _FeatureItem("Best planting time suggestions"),
                  _FeatureItem("Smart farming alerts & notifications"),
                  _FeatureItem("Future-ready ML insights"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // CONTINUE
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                try {
                  // 📍 REAL LOCATION
                  final loc = await LocationService.getCurrentLocation();
                  if (loc == null) {
                    throw Exception("Could not get location");
                  }
                  final double lat = loc.latitude;
                  final double lon = loc.longitude;

                  print("✅ Location fetched: lat=$lat, lon=$lon");

                  // 🌱 REAL SOIL TYPE
                  final String soilType =
                      await SoilService.getSoilType(lat, lon);

                  print("✅ Soil type fetched: $soilType");

                  // 🚜 Send to dashboard
                  onSubmit(lat, lon, soilType);

                  // Navigate to farmer dashboard
                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FarmerDashboard(
                          latitude: lat,
                          longitude: lon,
                          soilType: soilType,
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  print("❌ Error in farmer mode: $e");
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error: $e"),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                }
              },
              child: const Text(
                "Continue",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),

            const SizedBox(height: 10),

            // SKIP
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Not now",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// FEATURE ITEM WIDGET
class _FeatureItem extends StatelessWidget {
  final String text;
  const _FeatureItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
