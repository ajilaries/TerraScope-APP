import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Services/notification_service.dart'; // For sending push alerts
import '../Services/location_service.dart'; // For current location
import '../providers/emergency_provider.dart'; // For emergency contacts

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
      statusMessage = "Sending emergency alert...";
    });

    try {
      // 1️⃣ Get current location
      final loc = await LocationService.getCurrentLocation();
      if (loc == null) {
        setState(() {
          statusMessage = "Error: Could not get location";
          isSending = false;
        });
        return;
      }
      double lat = loc.latitude;
      double lon = loc.longitude;

      // 2️⃣ Create emergency message
      final emergencyMessage = "🚨 EMERGENCY ALERT 🚨\n"
          "I need immediate help!\n"
          "Location: $lat, $lon\n"
          "Time: ${DateTime.now().toString()}\n"
          "Please respond urgently!";

      // 3️⃣ Get emergency provider and send alert to all contacts
      final emergencyProvider = Provider.of<EmergencyProvider>(context, listen: false);

      // Load all contacts from both sources (signup + additional)
      final allContacts = await emergencyProvider.loadAllEmergencyContacts();

      if (allContacts.isEmpty) {
        setState(() {
          statusMessage = "No emergency contacts found. Please add contacts during signup or in settings.";
          isSending = false;
        });
        return;
      }

      // Send alert to all emergency contacts from both sources
      await emergencyProvider.sendEmergencyAlert(emergencyMessage);

      // 4️⃣ Send local notification (Disabled - notifications now handled by FCM server-side)
      // await NotificationService.showNotification(
      //   title: "Emergency Alert Sent",
      //   body: "Emergency alert sent to ${allContacts.length} contact(s). Location: $lat, $lon 🚨",
      // );

      // 5️⃣ Update status message
      setState(() {
        statusMessage = "Emergency alert sent successfully!\n"
            "Alert sent to ${allContacts.length} emergency contact(s).\n"
            "Check your SMS app for confirmation.";
      });

      setState(() => isSending = false);
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
        backgroundColor: Colors.orangeAccent,
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
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
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
