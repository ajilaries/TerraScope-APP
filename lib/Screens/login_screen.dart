import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/mode_provider.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? selectedMode;
  const LoginScreen({super.key, this.selectedMode});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();
  bool loading = false;
  final AuthService _auth = AuthService();

  void login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    final res = await _auth.login(
      email: emailC.text.trim(),
      password: passC.text,
    );

    if (res['ok']) {
      // Set mode if provided
      if (widget.selectedMode != null) {
        Provider.of<ModeProvider>(context, listen: false)
            .setMode(widget.selectedMode!);
      }
      // Navigate to main app
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Login failed')),
        );
      }
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.selectedMode != null)
                Text("Login to enable ${widget.selectedMode} mode",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailC,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : login,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text("Forgot Password?"),
              ),
              if (widget.selectedMode != null)
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SignupScreen(selectedMode: widget.selectedMode!),
                      ),
                    );
                  },
                  child: const Text("Don't have an account? Sign up"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
