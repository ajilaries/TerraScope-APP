import 'dart:ui';
import 'package:flutter/material.dart';
import '../Services/user_settings_service.dart';
import '../Services/fcm_service.dart';
import '../Services/anomaly_monitoring_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _anomalyMonitoringEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadMonitoringStatus();
  }

  Future<void> _loadMonitoringStatus() async {
    final enabled = await AnomalyMonitoringService.isMonitoringEnabled();
    setState(() {
      _anomalyMonitoringEnabled = enabled;
    });
  }

  Future<void> _toggleAnomalyMonitoring(bool value) async {
    await AnomalyMonitoringService.setMonitoringEnabled(value);
    setState(() {
      _anomalyMonitoringEnabled = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Weather anomaly monitoring enabled'
              : 'Weather anomaly monitoring disabled',
        ),
        backgroundColor: value ? Colors.green : Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _settingsTile(
            icon: Icons.language,
            title: "Language",
            subtitle: "Change app language",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.notifications_active,
            title: "Notifications",
            subtitle: "Manage alert preferences",
            onTap: () {},
          ),
          _settingsTileWithSwitch(
            icon: Icons.warning_amber,
            title: "Weather Anomaly Monitoring",
            subtitle: "Receive background notifications for weather alerts",
            value: _anomalyMonitoringEnabled,
            onChanged: _toggleAnomalyMonitoring,
          ),
          _settingsTile(
            icon: Icons.privacy_tip_outlined,
            title: "Privacy & Permissions",
            subtitle: "Location, data use, permissions",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.info_outline,
            title: "About Terrascope",
            subtitle: "Version, developer info",
            onTap: () {},
          ),

          // Test FCM Notification Button (Disabled - FCM notifications are now server-side)
          // Container(
          //   margin: const EdgeInsets.only(bottom: 14),
          //   padding: const EdgeInsets.all(18),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(18),
          //     color: Colors.blue.shade600.withOpacity(0.1),
          //     border: Border.all(color: Colors.blue.shade400.withOpacity(0.3)),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.blue.shade900.withOpacity(0.2),
          //         blurRadius: 15,
          //         offset: const Offset(0, 8),
          //       )
          //     ],
          //   ),
          //   child: ElevatedButton.icon(
          //     onPressed: () async {
          //       // Note: FCM notifications are now handled server-side
          //       // Use Firebase Admin SDK or Cloud Functions to send test notifications
          //       // await FCMService.sendTestNotification(
          //       //   title: 'Test Notification',
          //       //   body: 'This is a test FCM notification to verify push notifications are working.',
          //       //   type: 'test',
          //       // );
          //       if (mounted) {
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           const SnackBar(
          //             content: Text('Test notifications are now sent via FCM server. Use Firebase Console or Admin SDK.'),
          //             backgroundColor: Colors.blue,
          //           ),
          //         );
          //       }
          //     },
          //     icon: const Icon(Icons.notifications_active),
          //     label: const Text("Test FCM Notification"),
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Colors.blue.shade600,
          //       foregroundColor: Colors.white,
          //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            'Clear Cache',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'This will clear all cached data including nearby services, weather data, and other temporary files. This action cannot be undone.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _clearCache(context);
              },
              child: const Text(
                'Clear Cache',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearCache(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          backgroundColor: Color(0xFF1A1A1A),
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text(
                'Clearing cache...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );

    try {
      // Clear all caches
      await UserSettingsService.clearAllCaches();

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache cleared successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to clear cache: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withOpacity(0.07),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _settingsTileWithSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.07),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
            activeTrackColor: Colors.blue.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
