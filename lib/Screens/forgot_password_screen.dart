import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailC = TextEditingController();
  bool loading = false;
  bool resetLinkSent = false;
  final AuthService _auth = AuthService();

  void sendResetLink() async {
    if (!emailC.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid email")),
      );
      return;
    }
    setState(() => loading = true);

    final res = await _auth.sendResetLink(email: emailC.text.trim());

    if (res['statusCode'] == 200) {
      setState(() => resetLinkSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reset link sent to your email")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['body'] ?? 'Failed to send reset link')),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: emailC,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains('@'))
                    ? "Enter valid email"
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : sendResetLink,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Send Reset Link"),
              ),
              if (resetLinkSent) ...[
                const SizedBox(height: 10),
                const Text("Reset link sent to your email. Please check your email and click the link to reset your password.",
                    style: TextStyle(color: Colors.blue)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
