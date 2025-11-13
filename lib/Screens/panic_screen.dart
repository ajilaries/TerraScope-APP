import 'package:flutter/material.dart';
import '../Services/notification_service.dart'; // For sending push alerts
import '../Services/location_service.dart'; // For current location

class PanicScreen extends StatefulWidget {
  const PanicScreen({super.key});

  @override
  State<PanicScreen> createState() => _PanicScreenState();
}

class _PanicScreenState extends State<PanicScreen> {
  bool isSending = false;
  String statusMessage = "Press the button in an emergency";

  Future<void> _sendPanicAlert() async {
    setState(() {
      isSending = true;
      statusMessage = "Sending alert...";
    });

    try {
      // 1️⃣ Get current location
      final loc = await LocationService().getCurrentLocation();
      double lat = loc["latitude"];
      double lon = loc["longitude"];

      // 2️⃣ Get device token (optional, if needed for backend)
      String? token = await NotificationService.getDeviceToken();

      if (token == null) {
        setState(() {
          statusMessage = "Error: Device token not found";
          isSending = false;
        });
        return;
      }

      // 3️⃣ Send emergency alert via backend
      await NotificationService.sendEmergencyAlert(
        message: "I need help! 🚨",
        lat: lat,
        lon: lon,
        userId: token, // or any unique ID for the user
      );

      setState(() {
        statusMessage = "Alert sent successfully!";
        isSending = false;
      });
    } catch (e) {
      setState(() {
        statusMessage = "Failed to send alert: $e";
        isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panic / Safety"),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 100,
              ),
              const SizedBox(height: 20),
              Text(
                statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: isSending ? null : _sendPanicAlert,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: isSending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "SEND ALERT",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
