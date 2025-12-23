import 'package:flutter/material.dart';
import '../../Services/saftey_service.dart';
import '../../Widgets/saftey_card.dart';

class SafetyModeScreen extends StatefulWidget {
  const SafetyModeScreen({super.key});

  @override
  State<SafetyModeScreen> createState() => _SafetyModeScreenState();
}

class _SafetyModeScreenState extends State<SafetyModeScreen> {
  bool isSafetyModeOn = true;

  late final status = SafetyService.checkSafety(
    rainMm: 12,
    windSpeed: 18,
    visibility: 600,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Safety Mode"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text("Safety Mode"),
              value: isSafetyModeOn,
              onChanged: (val) {
                setState(() {
                  isSafetyModeOn = val;
                });
              },
            ),
            const SizedBox(height: 20),
            if (isSafetyModeOn) SafetyCard(status: status),
          ],
        ),
      ),
    );
  }
}
