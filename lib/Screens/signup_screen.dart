import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../providers/mode_provider.dart';

class SignupScreen extends StatefulWidget {
  final String selectedMode;
  const SignupScreen({super.key, required this.selectedMode});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();
  final TextEditingController emergencyContactC = TextEditingController();
  String gender = "male";
  bool loading = false;
  bool enableNotifications = true;
  bool enableLocationSharing = true;

  final AuthService _auth = AuthService();

  void signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    final res = await _auth.signup(
      name: nameC.text.trim(),
      email: emailC.text.trim(),
      password: passC.text,
      gender: gender,
      userMode: widget.selectedMode,
      emergencyContact: emergencyContactC.text.trim(),
      enableNotifications: enableNotifications,
      enableLocationSharing: enableLocationSharing,
    );

    if (res['statusCode'] == 200 || res['statusCode'] == 201) {
      // Auto login after signup
      final loginRes =
          await _auth.login(email: emailC.text.trim(), password: passC.text);
      if (!mounted) return;
      if (loginRes['ok']) {
        // set provider mode
        Provider.of<ModeProvider>(context, listen: false)
            .setMode(widget.selectedMode);
        // Save user preferences locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'emergency_contact', emergencyContactC.text.trim());
        await prefs.setBool('enable_notifications', enableNotifications);
        await prefs.setBool('enable_location_sharing', enableLocationSharing);
        // go to main app/home for this mode
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Signup succeeded but login failed")));
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Signup to enable mode"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Selected mode: ${widget.selectedMode}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameC,
                decoration: const InputDecoration(labelText: "Full name"),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Enter name" : null,
              ),
              TextFormField(
                controller: emailC,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => (v == null || !v.contains('@'))
                    ? "Enter valid email"
                    : null,
              ),
              TextFormField(
                controller: passC,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (v) =>
                    (v == null || v.length < 6) ? "Min 6 chars" : null,
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              TextFormField(
                controller: emergencyContactC,
                decoration: const InputDecoration(
                    labelText: "Emergency Contact Number"),
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? "Enter emergency contact number"
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("Enable Notifications: "),
                  Switch(
                    value: enableNotifications,
                    onChanged: (v) => setState(() => enableNotifications = v),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text("Enable Location Sharing: "),
                  Switch(
                    value: enableLocationSharing,
                    onChanged: (v) => setState(() => enableLocationSharing = v),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : signup,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Signup & Activate Mode"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
