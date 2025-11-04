import 'package:flutter/material.dart';

class FooterButtons extends StatelessWidget {
  const FooterButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _footerButton(Icons.shield, "Precautions"),
          _footerButton(Icons.newspaper, "News"),
          _footerButton(Icons.location_on, "Other Regions"),
          _footerButton(Icons.phone, "Helplines"),
        ],
      ),
    );
  }

  Widget _footerButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
