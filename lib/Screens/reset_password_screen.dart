import 'package:flutter/material.dart';
import '../Services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController passC = TextEditingController();
  bool loading = false;
  final AuthService _auth = AuthService();

  void resetPassword() async {
    setState(() => loading = true);

    final res = await _auth.resetPasswordWithOtp(
      email: widget.email,
      otp: widget.otp,
      newPassword: passC.text.trim(),
    );

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset successful")),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Failed')),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Password")),
      body: Column(
        children: [
          TextField(controller: passC),
          ElevatedButton(
            onPressed: resetPassword,
            child: const Text("Reset Password"),
          )
        ],
      ),
    );
  }
}