import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

      // 3️⃣ Get emergency contact from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final emergencyContact =
          prefs.getString('emergency_contact') ?? ""; // Default fallback

      // Send alert to emergency contact
      final String testPhoneNumber =
          emergencyContact; // Use saved emergency contact

      bool alertSent = false;

      try {
        // Send SMS to your own number for testing
        final smsUri = Uri.parse(
            'sms:$testPhoneNumber?body=${Uri.encodeComponent(emergencyMessage)}');
        debugPrint("Attempting to launch SMS: $smsUri");

        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri, mode: LaunchMode.externalApplication);
          alertSent = true;
          debugPrint("Test alert sent to: $testPhoneNumber");
        } else {
          // Fallback: try without body parameter
          final fallbackUri = Uri.parse('sms:$testPhoneNumber');
          if (await canLaunchUrl(fallbackUri)) {
            await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
            alertSent = true;
            debugPrint("Fallback SMS sent to: $testPhoneNumber (without body)");
          } else {
            debugPrint("Could not launch SMS app - both URI formats failed");
          }
        }
      } catch (e) {
        debugPrint("Failed to send test alert: $e");
      }

      // 4️⃣ Send local notification
      await NotificationService.showNotification(
        title: "Emergency Alert Sent",
        body: "Test alert sent to your number. Location: $lat, $lon 🚨",
      );

      // 5️⃣ Update status message
      if (alertSent) {
        setState(() {
          statusMessage = "Test alert sent to your phone number!\n"
              "Check your SMS app for the emergency message.";
        });
      } else {
        setState(() {
          statusMessage = "Failed to send test alert. Check your phone number.";
        });
      }

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
        title: const Text("Panic / Safety (TEST MODE)"),
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
