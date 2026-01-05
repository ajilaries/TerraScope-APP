import 'package:flutter/material.dart';

class TravelerMapPreview extends StatelessWidget {
  const TravelerMapPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          "Map preview\n(plug Google Maps here)",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
