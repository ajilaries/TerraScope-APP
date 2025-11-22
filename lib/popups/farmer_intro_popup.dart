import 'package:flutter/material.dart';

Future<void> showFarmerIntroPopup(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false, 
    builder: (context) {
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

              // IMAGE / ILLUSTRATION PLACEHOLDER
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

              // SUBTITLE
              Text(
                "Grow smarter with weather-based insights, crop guidance, and farming tools tailored for you.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 18),

              // FEATURE HIGHLIGHTS BOX
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
                  Navigator.pop(context); // close this popup
                  showThemeSelectPopup(context); // open next popup
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

              // CANCEL
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Not now",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// --- SUPPORTING WIDGET ---
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
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
Future<void> showThemeSelectPopup(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      String selected = 'green'; // local selected key
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Choose Farmer Theme",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Pick a theme for Farmer Mode. You can change it later in settings.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),

                  // Theme options row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _themeOption(
                        label: "Green Nature",
                        selected: selected == 'green',
                        onTap: () => setState(() => selected = 'green'),
                        preview: Container(
                          width: 60,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(colors: [Colors.green.shade300, Colors.green.shade700]),
                          ),
                        ),
                      ),
                      _themeOption(
                        label: "Classic",
                        selected: selected == 'classic',
                        onTap: () => setState(() => selected = 'classic'),
                        preview: Container(
                          width: 60,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(colors: [Colors.blue.shade200, Colors.indigo.shade400]),
                          ),
                        ),
                      ),
                      _themeOption(
                        label: "Dark Farm",
                        selected: selected == 'dark',
                        onTap: () => setState(() => selected = 'dark'),
                        preview: Container(
                          width: 60,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      // Save selected theme to local state / provider (later).
                      Navigator.pop(context); // close theme popup
                      // proceed to personalization popup (or dashboard)
                      Future.microtask(() => showPersonalizationPopup(context));
                    },
                    child: const Text("Apply & Continue"),
                  ),

                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // optionally go straight to dashboard:
                      // Future.microtask(() => Navigator.pushReplacement(...));
                    },
                    child: const Text("Skip"),
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

// small helper widget for theme tile
Widget _themeOption({
  required Widget preview,
  required String label,
  required bool selected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? Colors.green.shade700 : Colors.grey.shade300, width: selected ? 2 : 1),
          ),
          child: preview,
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    ),
  );
}

