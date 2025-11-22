import 'package:flutter/material.dart';

Future<void> showPersonalizationPopup(BuildContext context) {
  String? selectedFarmType;
  String? selectedCrop;
  String? selectedIrrigation;
  String? selectedRegion;

  final List<String> farmTypes = [
    "Small-scale",
    "Medium-scale",
    "Large-scale",
  ];

  final List<String> crops = [
    "Rice",
    "Wheat",
    "Sugarcane",
    "Cotton",
    "Vegetables",
    "Banana",
    "Maize",
  ];

  final List<String> irrigation = [
    "Rain-fed",
    "Canal Irrigation",
    "Drip Irrigation",
    "Sprinkler Irrigation",
  ];

  final List<String> regions = [
    "Kerala",
    "Tamil Nadu",
    "Karnataka",
    "Andhra Pradesh",
    "Maharashtra",
    "Gujarat",
  ];

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TITLE
                  Text(
                    "Personalize Your Farming Mode",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // FARM TYPE
                  _dropdownSection(
                    title: "Farm Type",
                    value: selectedFarmType,
                    items: farmTypes,
                    onChanged: (val) => setState(() => selectedFarmType = val),
                  ),

                  const SizedBox(height: 15),

                  // MAIN CROP
                  _dropdownSection(
                    title: "Main Crop",
                    value: selectedCrop,
                    items: crops,
                    onChanged: (val) => setState(() => selectedCrop = val),
                  ),

                  const SizedBox(height: 15),

                  // IRRIGATION TYPE
                  _dropdownSection(
                    title: "Irrigation Type",
                    value: selectedIrrigation,
                    items: irrigation,
                    onChanged: (val) =>
                        setState(() => selectedIrrigation = val),
                  ),

                  const SizedBox(height: 15),

                  // REGION
                  _dropdownSection(
                    title: "Region",
                    value: selectedRegion,
                    items: regions,
                    onChanged: (val) => setState(() => selectedRegion = val),
                  ),

                  const SizedBox(height: 25),

                  // CONTINUE BUTTON
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 35,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      // CHECKS
                      if (selectedFarmType == null ||
                          selectedCrop == null ||
                          selectedIrrigation == null ||
                          selectedRegion == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please fill all fields"),
                          ),
                        );
                        return;
                      }

                      Navigator.pop(context);

                      // TODO → Go to FARMER DASHBOARD SCREEN
                      // Navigator.push(context,
                      //   MaterialPageRoute(builder: (_) => FarmerDashboard()),
                      // );
                    },
                    child: const Text(
                      "Continue",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // BACK / CANCEL
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Back",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    },
  );
}

// UI DROPDOWN WIDGET
Widget _dropdownSection({
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
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          underline: const SizedBox(),
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(e),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    ],
  );
}
