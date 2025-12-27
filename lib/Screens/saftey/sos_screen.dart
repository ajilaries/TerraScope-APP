import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/safety_provider.dart';
import '../../models/emergency_contact.dart';
import 'package:url_launcher/url_launcher.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  int _countdownSeconds = 10;
  bool _countdownActive = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    if (_countdownActive) return;

    setState(() {
      _countdownActive = true;
      _countdownSeconds = 10;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _countdownActive) {
        setState(() => _countdownSeconds--);
        if (_countdownSeconds > 0) {
          _startCountdown();
        } else {
          // Auto-trigger SOS when countdown finishes
          _triggerSOS();
        }
      }
    });
  }

  void _cancelCountdown() {
    setState(() {
      _countdownActive = false;
      _countdownSeconds = 10;
    });
  }

  Future<void> _triggerSOS() async {
    _cancelCountdown();

    // Show SOS triggered dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('SOS Triggered'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Emergency services are being contacted.'),
            SizedBox(height: 12),
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Calling emergency contact...'),
          ],
        ),
      ),
    );

    // Get emergency contact from SharedPreferences (entered during signup)
    final prefs = await SharedPreferences.getInstance();
    final emergencyContact = prefs.getString('emergency_contact') ??
        "+919072805856"; // Default fallback

    // Auto-call emergency contact from signup
    final Uri launchUri = Uri(scheme: 'tel', path: emergencyContact);

    await Future.delayed(const Duration(seconds: 2));

    try {
      await launchUrl(launchUri);
    } catch (e) {
      print('Error calling emergency contact: $e');
    }

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency SOS'),
        elevation: 0,
      ),
      body: Consumer<SafetyProvider>(
        builder: (context, safetyProvider, _) {
          return Column(
            children: [
              // Main SOS Button Area
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_countdownActive)
                        Column(
                          children: [
                            const Icon(
                              Icons.sos,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Emergency SOS',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hold to activate emergency services',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 48),
                          ],
                        ),

                      // Main SOS Button
                      GestureDetector(
                        onLongPress: _startCountdown,
                        onLongPressUp: () {
                          if (_countdownSeconds == 10) {
                            _cancelCountdown();
                          }
                        },
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 1.0, end: 1.1).animate(
                            CurvedAnimation(
                              parent: _pulseController,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.phone,
                                  size: 56,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _countdownActive ? 'CALLING' : 'SOS',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Countdown Timer
                      if (_countdownActive)
                        Padding(
                          padding: const EdgeInsets.only(top: 48),
                          child: Column(
                            children: [
                              Text(
                                'Calling in',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 3,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '$_countdownSeconds',
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _cancelCountdown,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 48,
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text('CANCEL'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Emergency Contacts List
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quick Access Contacts',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (safetyProvider.emergencyContacts.isEmpty)
                            Center(
                              child: Text(
                                'No emergency contacts added',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                          else
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: safetyProvider.emergencyContacts
                                    .take(3)
                                    .map(
                                      (contact) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12),
                                        child: _QuickContactButton(
                                          contact: contact,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickContactButton extends StatelessWidget {
  final EmergencyContact contact;

  const _QuickContactButton({required this.contact});

  Future<void> _makeCall() async {
    final Uri launchUri = Uri(scheme: 'tel', path: contact.phoneNumber);
    try {
      await launchUrl(launchUri);
    } catch (e) {
      print('Error calling: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _makeCall,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              contact.icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              contact.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
