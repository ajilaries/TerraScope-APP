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
  final TextEditingController otpC = TextEditingController();
  final TextEditingController newPassC = TextEditingController();
  bool loading = false;
  bool otpSent = false;
  final AuthService _auth = AuthService();

  void sendOtp() async {
    if (!emailC.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid email")),
      );
      return;
    }
    setState(() => loading = true);

    final res = await _auth.sendOtp(email: emailC.text.trim());

    if (res['statusCode'] == 200) {
      setState(() => otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP sent to your email")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['body'] ?? 'Failed to send OTP')),
      );
    }

    setState(() => loading = false);
  }

  void resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    final res = await _auth.resetPassword(
      email: emailC.text.trim(),
      otp: otpC.text,
      newPassword: newPassC.text,
    );

    if (res['statusCode'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset successful")),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['body'] ?? 'Failed to reset password')),
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
              if (!otpSent) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: loading ? null : sendOtp,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Send OTP"),
                ),
              ] else ...[
                const SizedBox(height: 20),
                TextFormField(
                  controller: otpC,
                  decoration: const InputDecoration(labelText: "OTP"),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v == null || v.length != 6) ? "Enter 6-digit OTP" : null,
                ),
                TextFormField(
                  controller: newPassC,
                  decoration: const InputDecoration(labelText: "New Password"),
                  obscureText: true,
                  validator: (v) =>
                      (v == null || v.length < 6) ? "Min 6 chars" : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: loading ? null : resetPassword,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Reset Password"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
