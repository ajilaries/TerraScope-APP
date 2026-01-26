import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/device_service.dart';
import '../providers/mode_provider.dart';
import '../providers/emergency_provider.dart';
import '../models/emergency_contact.dart';

class SignupScreen extends StatefulWidget {
  final String? selectedMode;
  const SignupScreen({super.key, this.selectedMode});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();
  final TextEditingController ageC = TextEditingController();
  final TextEditingController phoneC = TextEditingController();
  final TextEditingController addressC = TextEditingController();
  final TextEditingController otpC = TextEditingController();
  String gender = "male";
  bool loading = false;
  bool enableNotifications = true;
  bool enableLocationSharing = true;
  bool otpSent = false;
  bool otpVerified = false;

  List<Map<String, dynamic>> emergencyContacts = [];

  final AuthService _auth = AuthService();

  void addEmergencyContact() {
    setState(() {
      emergencyContacts.add({
        'name': '',
        'phone': '',
        'email': '',
        'type': EmergencyContactType.family.name,
        'notes': '',
        'isPrimary': emergencyContacts.isEmpty, // First one is primary
      });
    });
  }

  void removeEmergencyContact(int index) {
    setState(() {
      emergencyContacts.removeAt(index);
      // Ensure at least one primary if any contacts remain
      if (emergencyContacts.isNotEmpty &&
          !emergencyContacts.any((c) => c['isPrimary'])) {
        emergencyContacts[0]['isPrimary'] = true;
      }
    });
  }

  void sendOtp() async {
    if (!emailC.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Enter valid email first"),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    setState(() => loading = true);

    final res = await _auth.sendOtp(email: emailC.text.trim());

    if (res['ok']) {
      setState(() => otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("OTP sent to your email. Please enter the OTP to verify."),
          backgroundColor: Colors.green.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Failed to send OTP'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    setState(() => loading = false);
  }

  void verifyOtp() async {
    if (otpC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Enter OTP first"),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    setState(() => loading = true);

    final res = await _auth.verifyOtp(email: emailC.text.trim(), otp: otpC.text.trim());

    if (res['ok']) {
      setState(() => otpVerified = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Email verified successfully"),
          backgroundColor: Colors.green.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Invalid OTP'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    setState(() => loading = false);
  }

  void signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!otpVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please verify your email with OTP first"),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    if (emergencyContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Add at least one emergency contact"),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => loading = true);

    // Get device token for one account per device
    final deviceToken = await DeviceService.getDeviceToken();

    final res = await _auth.signup(
      name: nameC.text.trim(),
      email: emailC.text.trim(),
      password: passC.text,
      otp: otpC.text.trim(),
      gender: gender,
      userMode: widget.selectedMode ?? "default",
      age: int.parse(ageC.text),
      phoneNumber: phoneC.text.trim(),
      address: addressC.text.trim(),
      emergencyContacts: emergencyContacts,
      deviceToken: deviceToken,
    );

    if (res['statusCode'] == 200 || res['statusCode'] == 201) {
      // Save emergency contacts using provider
      final emergencyProvider =
          Provider.of<EmergencyProvider>(context, listen: false);
      List<EmergencyContact> contacts = emergencyContacts
          .map((c) => EmergencyContact(
                id: DateTime.now().millisecondsSinceEpoch.toString() +
                    c['name'], // Simple ID generation
                name: c['name'],
                phoneNumber: c['phone'],
                email: c['email'],
                type: EmergencyContactType.values
                    .firstWhere((e) => e.name == c['type']),
                notes: c['notes'],
                isPrimary: c['isPrimary'],
              ))
          .toList();
      await emergencyProvider.completeSignup(contacts);

      // Auto login after signup
      final loginRes =
          await _auth.login(email: emailC.text.trim(), password: passC.text);
      if (!mounted) return;
      if (loginRes['ok']) {
        // Set provider mode
        Provider.of<ModeProvider>(context, listen: false)
            .setMode(widget.selectedMode ?? "default");
        // Save user preferences locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('enable_notifications', enableNotifications);
        await prefs.setBool('enable_location_sharing', enableLocationSharing);
        await prefs.setBool('has_completed_signup', true);
        // Go to main app/home for this mode
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Signup succeeded but login failed"),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } else {
      if (!mounted) return;
      final body = res['body'] ?? {};
      final msg = body is Map && body['detail'] != null
          ? body['detail']
          : res['body'] ?? 'Signup failed';
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(
              content: Text(msg.toString()),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ));
      }
    }

    setState(() => loading = false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFF093FB),
              Color(0xFFF5576C),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mode indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Text(
                              "Selected mode: ${widget.selectedMode ?? "default"}",
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Basic Info Section
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: Colors.blue.shade400,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                          validator: (v) => (v == null || !v.contains('@'))
                              ? "Enter valid email"
                              : null,
                        ),
                        DropdownButtonFormField<String>(
                          value: contact['type'],
                          decoration: const InputDecoration(labelText: "Type"),
                          items: EmergencyContactType.values
                              .map((type) => DropdownMenuItem(
                                    value: type.name,
                                    child: Text(type.name.toUpperCase()),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => contact['type'] =
                              v ?? EmergencyContactType.family.name),
                        ),
                        TextFormField(
                          initialValue: contact['notes'],
                          decoration: const InputDecoration(
                              labelText: "Notes (Optional)"),
                          onChanged: (v) => contact['notes'] = v,
                        ),
                        CheckboxListTile(
                          title: const Text("Set as Primary Contact"),
                          value: contact['isPrimary'],
                          onChanged: (v) {
                            setState(() {
                              // Uncheck all others if this is checked
                              if (v == true) {
                                for (var c in emergencyContacts) {
                                  c['isPrimary'] = false;
                                }
                              }
                              contact['isPrimary'] = v ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
              ElevatedButton.icon(
                onPressed: addEmergencyContact,
                icon: const Icon(Icons.add),
                label: const Text("Add Emergency Contact"),
              ),

              const SizedBox(height: 20),

              // Preferences Section
              const Text("Preferences",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text("Enable Notifications"),
                value: enableNotifications,
                onChanged: (v) => setState(() => enableNotifications = v),
              ),
              SwitchListTile(
                title: const Text("Enable Location Sharing"),
                value: enableLocationSharing,
                onChanged: (v) => setState(() => enableLocationSharing = v),
              ),

              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: loading ? null : signup,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Signup & Activate Mode",
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
