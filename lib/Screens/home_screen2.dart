import 'package:flutter/material.dart';
import '../Widgets/footer_buttons.dart'; //here i have imported the footer buttons

class HomeScreen2 extends StatelessWidget {
  const HomeScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.3),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [FooterButtons(), SizedBox(height: 20)],
        ),
      ),
    );
  }
}
