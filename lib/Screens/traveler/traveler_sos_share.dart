import 'package:flutter/material.dart';

class TravelerSOSShare extends StatelessWidget {
  final bool shareLocation;
  final VoidCallback onSOS;
  final VoidCallback onToggleShare;

  const TravelerSOSShare({
    super.key,
    required this.shareLocation,
    required this.onSOS,
    required this.onToggleShare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onSOS,
            icon: const Icon(Icons.report),
            label: const Text("SOS"),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onToggleShare,
            icon: Icon(shareLocation ? Icons.share : Icons.share_outlined),
            label: Text(shareLocation ? "Sharing" : "Share Location"),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700),
          ),
        ),
      ],
    );
  }
}
