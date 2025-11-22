import 'package:flutter/material.dart';

class FarmerPersonalizationScreen extends StatefulWidget {
  const FarmerPersonalizationScreen({super.key});

  @override
  State<FarmerPersonalizationScreen> createState() =>
      _FarmerPersonalizationScreenState();
}

class _FarmerPersonalizationScreenState
    extends State<FarmerPersonalizationScreen> {
  String? cropType;
  String? landSize;
  String? irrigation;

  final List<String> cropOptions = [
    "Paddy",
    "Wheat",
    "Sugarcane",
    "Vegetables",
    "Fruits",
    "Tea",
    "Coffee",
    "Others"
  ];

  final List<String> landOptions = [
    "< 1 Acre",
    "1 - 3 Acres",
    "3 - 5 Acres",
    "5+ Acres",
  ];

  final List<String> irrigationOptions = [
    "Rain-fed",
    "Drip irrigation",
    "Sprinkler",
    "Canal water",
    "Borewell"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("Farmer Personalization"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Help us personalize your weather insights 🌾",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800),
            ),
            const SizedBox(height: 25),

            // CROP TYPE
            buildDropdown(
              title: "Primary Crop You Grow",
              value: cropType,
              items: cropOptions,
              onChanged: (v) => setState(() => cropType = v),
            ),

            const SizedBox(height: 20),

            // LAND SIZE
            buildDropdown(
              title: "Land Size",
              value: landSize,
              items: landOptions,
              onChanged: (v) => setState(() => landSize = v),
            ),

            const SizedBox(height: 20),

            // IRRIGATION
            buildDropdown(
              title: "Irrigation Method",
              value: irrigation,
              items: irrigationOptions,
              onChanged: (v) => setState(() => irrigation = v),
            ),

            const Spacer(),

            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: cropType == null ||
                        landSize == null ||
                        irrigation == null
                    ? null
                    : () {
                        Navigator.pop(context, {
                          "crop": cropType,
                          "land": landSize,
                          "irrigation": irrigation,
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Save Preferences",
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Reusable Dropdown Widget
  Widget buildDropdown({
    required String title,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: const Text("Select"),
              items: items
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
