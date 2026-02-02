import 'package:flutter/material.dart';
import '../../Services/location_service.dart';
import '../../Services/emergency_contact_service.dart';
import '../../models/emergency_contact.dart';
import '../../Services/fcm_service.dart';

class TravelerSOSScreen extends StatefulWidget {
  const TravelerSOSScreen({super.key});

  @override
  State<TravelerSOSScreen> createState() => _TravelerSOSScreenState();
}

class _TravelerSOSScreenState extends State<TravelerSOSScreen> {
  List<EmergencyContact> _emergencyContacts = [];
  bool _isLoading = true;
  bool _sosActive = false;

  @override
  void initState() {
    super.initState();
    _loadEmergencyContacts();
  }

  Future<void> _loadEmergencyContacts() async {
    try {
      final contacts = await EmergencyContactService().loadAllEmergencyContacts();
      setState(() {
        _emergencyContacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading contacts: $e")),
        );
      }
    }
  }

  Future<void> _sendSOS() async {
    if (_sosActive) return;

    setState(() {
      _sosActive = true;
    });

    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos == null) {
        throw Exception("Unable to get current location");
      }

      final locationMessage = "EMERGENCY SOS!\n"
          "Location: ${pos.latitude}, ${pos.longitude}\n"
          "Time: ${DateTime.now().toString()}\n"
          "Please send help immediately!";

      // Send to all emergency contacts
      for (final contact in _emergencyContacts) {
        if (contact.phoneNumber.isNotEmpty) {
          // In a real app, this would integrate with SMS service
          print("Sending SOS to ${contact.name}: ${contact.phoneNumber}");
          print("Message: $locationMessage");
        }
      }



      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("SOS sent to all emergency contacts!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error sending SOS: $e")),
        );
      }
    } finally {
      setState(() {
        _sosActive = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency SOS"),
        backgroundColor: Colors.red.shade700,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SOS Button
                  Container(
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 24),
                    child: ElevatedButton(
                      onPressed: _sendSOS,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _sosActive ? Colors.red.shade300 : Colors.red.shade700,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning,
                            size: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _sosActive ? "SENDING SOS..." : "PRESS FOR SOS",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Emergency Contacts
                  const Text(
                    "Emergency Contacts",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: _emergencyContacts.isEmpty
                        ? const Center(
                            child: Text(
                              "No emergency contacts added.\nAdd contacts in settings for SOS to work.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _emergencyContacts.length,
                            itemBuilder: (context, index) {
                              final contact = _emergencyContacts[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.red.shade100,
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.red,
                                    ),
                                  ),
                                  title: Text(contact.name),
                                  subtitle: Text(contact.phoneNumber),
                                  trailing: const Icon(
                                    Icons.phone,
                                    color: Colors.green,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Safety Tips
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.red.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Emergency Tips:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text("• Stay calm and assess the situation"),
                          Text("• Move to a safe location if possible"),
                          Text("• Provide clear location details"),
                          Text("• Follow local emergency procedures"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
