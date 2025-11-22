import 'package:flutter/material.dart';

Future<void> showPersonalizationPopup(BuildContext context) {
  String? selectedCrop;
  String? selectedLanguage;

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TITLE
                  Text(
                    "Personalise Your Experience",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // LANGUAGE SELECTOR
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Preferred Language",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    value: selectedLanguage,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    items: ["English", "Tamil", "Malayalam", "Hindi"]
                        .map(
                          (lang) => DropdownMenuItem(
                            value: lang,
                            child: Text(lang),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // MAIN CROP SELECTION
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Your Primary Crop",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    value: selectedCrop,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    items: [
                      "Rice",
                      "Wheat",
                      "Banana",
                      "Vegetables",
                      "Coconut",
                      "Sugarcane",
                    ]
                        .map(
                          (crop) => DropdownMenuItem(
                            value: crop,
                            child: Text(crop),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCrop = value;
                      });
                    },
                  ),

                  const SizedBox(height: 25),

                  // CONTINUE BUTTON
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);

                      // TODO: Open Farmer Dashboard Next
                      // Navigator.push(...);
                    },
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // BACK
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Back",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
