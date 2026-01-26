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
        const SnackBar(content: Text("Enter valid email first")),
      );
      return;
    }
    setState(() => loading = true);

    final res = await _auth.sendOtp(email: emailC.text.trim());

    if (res['ok']) {
      setState(() => otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP sent to your email. Please enter the OTP to verify.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Failed to send OTP')),
      );
    }

    setState(() => loading = false);
  }

  void verifyOtp() async {
    if (otpC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter OTP first")),
      );
      return;
    }
    setState(() => loading = true);

    final res = await _auth.verifyOtp(email: emailC.text.trim(), otp: otpC.text.trim());

    if (res['ok']) {
      setState(() => otpVerified = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email verified successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Invalid OTP')),
      );
    }

    setState(() => loading = false);
  }



  void signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!otpVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please verify your email with OTP first")),
      );
      return;
    }
    if (emergencyContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least one emergency contact")),
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
            const SnackBar(content: Text("Signup succeeded but login failed")),
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
            .showSnackBar(SnackBar(content: Text(msg.toString())));
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
      appBar: AppBar(
        title: const Text("Signup to enable mode"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Selected mode: ${widget.selectedMode ?? "default"}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Basic Info Section
              const Text("Basic Information",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameC,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Enter full name" : null,
              ),
              TextFormField(
                controller: emailC,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains('@'))
                    ? "Enter valid email"
                    : null,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: loading ? null : sendOtp,
                child: const Text("Send OTP"),
              ),
              if (otpSent && !otpVerified) ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: otpC,
                  decoration: const InputDecoration(labelText: "Enter OTP"),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? "Enter OTP"
                      : null,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: loading ? null : verifyOtp,
                  child: const Text("Verify OTP"),
                ),
              ],
              if (otpVerified) ...[
                const SizedBox(height: 10),
                const Text("Email verified successfully",
                    style: TextStyle(color: Colors.green)),
              ],
              TextFormField(
                controller: passC,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (v) => (v == null || v.length < 6)
                    ? "Password must be at least 6 characters"
                    : null,
              ),
              TextFormField(
                controller: ageC,
                decoration: const InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Enter age";
                  final age = int.tryParse(v);
                  if (age == null || age < 13 || age > 120)
                    return "Enter valid age (13-120)";
                  return null;
                },
              ),
              TextFormField(
                controller: phoneC,
                decoration: const InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? "Enter phone number"
                    : null,
              ),
              TextFormField(
                controller: addressC,
                decoration: const InputDecoration(labelText: "Address"),
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Enter address" : null,
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  const Text("Gender: "),
                  DropdownButton<String>(
                    value: gender,
                    items: const [
                      DropdownMenuItem(value: "male", child: Text("Male")),
                      DropdownMenuItem(value: "female", child: Text("Female")),
                      DropdownMenuItem(value: "other", child: Text("Other")),
                    ],
                    onChanged: (v) => setState(() => gender = v ?? "male"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Emergency Contacts Section
              const Text("Emergency Contacts",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...emergencyContacts.asMap().entries.map((entry) {
                final index = entry.key;
                final contact = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text("Contact ${index + 1}"),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => removeEmergencyContact(index),
                            ),
                          ],
                        ),
                        TextFormField(
                          initialValue: contact['name'],
                          decoration: const InputDecoration(labelText: "Name"),
                          onChanged: (v) => contact['name'] = v,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? "Enter name"
                              : null,
                        ),
                        TextFormField(
                          initialValue: contact['phone'],
                          decoration: const InputDecoration(labelText: "Phone"),
                          keyboardType: TextInputType.phone,
                          onChanged: (v) => contact['phone'] = v,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? "Enter phone"
                              : null,
                        ),
                        TextFormField(
                          initialValue: contact['email'],
                          decoration: const InputDecoration(labelText: "Email"),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (v) => contact['email'] = v,
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
