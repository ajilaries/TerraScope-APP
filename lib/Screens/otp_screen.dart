import 'package:flutter/material.dart';
import '../Services/auth_service.dart';
import 'reset_password_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController otpC = TextEditingController();
  bool loading = false;
  final AuthService _auth = AuthService();

  void verifyOtp() async {
    setState(() => loading = true);

    final res = await _auth.verifyOtp(
      email: widget.email,
      otp: otpC.text.trim(),
    );

    if (res['success'] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            email: widget.email,
            otp: otpC.text.trim(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Invalid OTP')),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter OTP")),
      body: Column(
        children: [
          TextField(controller: otpC),
          ElevatedButton(
            onPressed: verifyOtp,
            child: const Text("Verify OTP"),
          )
        ],
      ),
    );
  }
}
