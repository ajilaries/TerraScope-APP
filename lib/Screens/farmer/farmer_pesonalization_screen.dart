import 'package:flutter/material.dart';

class FarmerPersonalizationScreen extends StatefulWidget {
  final double lat;
  final double lon;

  const FarmerPersonalizationScreen({
    super.key,
    required this.lat,
    required this.lon,
  });

  @override
  State<FarmerPersonalizationScreen> createState() =>
      _FarmerPersonalizationScreenState();
}

class _FarmerPersonalizationScreenState
    extends State<FarmerPersonalizationScreen> {
  String? cropType;
  String? landSize;
  String? irrigation;

  bool loadingCrops = true;
  List<String> cropOptions = [];

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
    "Borewell",
  ];

  // @override
  // void initState() {
  //   super.initState();
  //   // _loadDistrictCrops();
  // }

  // /// --------------------------------------------------------------------------
  // /// STEP 1: Reverse geocode → get state & district
  // /// --------------------------------------------------------------------------
  // Future<Map<String, String>> _getStateDistrict() async {
  //   try {
  //     final placemarks = await placemarkFromCoordinates(
  //       widget.lat,
  //       widget.lon,
  //     );

  //     final p = placemarks.first;

  //     return {
  //       "state": p.administrativeArea ?? "Unknown",
  //       "district": p.subAdministrativeArea ?? "Unknown",
  //     };
  //   } catch (e) {
  //     print("Error getting district: $e");
  //     return {"state": "Unknown", "district": "Unknown"};
  //   }
  // }

  // Future<void> _loadDistrictCrops() async {
  //   final loc = await _getStateDistrict();

  //   String state = loc["state"] ?? "Unknown";
  //   String district = loc["district"] ?? "Unknown";

  //   print("📍 Detected: $district, $state");

  //   final crops = await CropService.getCropsForDistrict(
  //     state: state,
  //     district: district,
  //   );

  //   setState(() {
  //     cropOptions = crops.isNotEmpty
  //         ? crops
  //         : [
  //             "Paddy",
  //             "Vegetables",
  //             "Fruits",
  //             "Other"
  //           ]; // fallback if district not in JSON
  //     loadingCrops = false;
  //   });
  // }

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
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 25),

            // ---- CROP TYPE ----
            loadingCrops
                ? const Center(child: CircularProgressIndicator())
                : buildDropdown(
                    title: "Primary Crop You Grow",
                    value: cropType,
                    items: cropOptions,
                    onChanged: (v) => setState(() => cropType = v),
                  ),

            const SizedBox(height: 20),

            // ---- LAND SIZE ----
            buildDropdown(
              title: "Land Size",
              value: landSize,
              items: landOptions,
              onChanged: (v) => setState(() => landSize = v),
            ),

            const SizedBox(height: 20),

            // ---- IRRIGATION ----
            buildDropdown(
              title: "Irrigation Method",
              value: irrigation,
              items: irrigationOptions,
              onChanged: (v) => setState(() => irrigation = v),
            ),

            const Spacer(),

            // ---- SAVE BUTTON ----
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
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Reusable Dropdown Widget
  // --------------------------------------------------------------------------
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
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
