import 'package:flutter/material.dart';
import 'package:terra_scope_apk/popups/theme_select_popup.dart';

class FarmerIntroPopup extends StatelessWidget {
  final Function(double lat, double lon, String soilType) onSubmit;

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
            Text(
              "Grow smarter with weather-based insights, crop guidance, and farming tools tailored for you.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.4),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _FeatureItem("Farming Conditions"),
                  _FeatureItem("Crop Recommendations"),
                  _FeatureItem("Irrigation Helper"),
                  _FeatureItem("Market Price Updates"),
                  _FeatureItem("Disease Scan (UI)"),
                  _FeatureItem("Smart Alerts"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // TEMP dummy data for testing
                onSubmit(11.02, 76.95, "Loamy");
                Navigator.pop(context); // close popup
              },
              child: const Text(
                "Continue",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
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

class _FeatureItem extends StatelessWidget {
  final String text;
  const _FeatureItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: Colors.green),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
