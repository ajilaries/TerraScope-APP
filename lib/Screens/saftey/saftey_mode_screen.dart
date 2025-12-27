import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/safety_provider.dart';
import '../../Services/saftey_service.dart';
import '../../Services/weather_services.dart';
import '../../Services/location_service.dart';
import '../../Services/notification_service.dart';
import '../../Widgets/detailed_safety_card.dart';
import '../../Widgets/emergency_contact_card.dart';
import '../../Widgets/safety_history_card.dart';
import '../../utils/safety_utils.dart';

class SafetyModeScreen extends StatefulWidget {
  const SafetyModeScreen({super.key});

  @override
  State<SafetyModeScreen> createState() => _SafetyModeScreenState();
}

class _SafetyModeScreenState extends State<SafetyModeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Weather parameters
  double _rainMm = 12;
  double _windSpeed = 18;
  int _visibility = 600;
  double _temperature = 25;
  int _humidity = 60;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize safety mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SafetyProvider>().initializeSafetyMode();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateSafetyCheck() {
    context.read<SafetyProvider>().checkCurrentSafety(
          rainMm: _rainMm,
          windSpeed: _windSpeed,
          visibility: _visibility,
          temperature: _temperature,
          humidity: _humidity,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Safety Mode"),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.shield), text: 'Status'),
            Tab(icon: Icon(Icons.emergency), text: 'Contacts'),
            Tab(icon: Icon(Icons.history), text: 'History'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
      ),
      body: Consumer<SafetyProvider>(
        builder: (context, safetyProvider, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              // Status Tab
              _buildStatusTab(context, safetyProvider),

              // Emergency Contacts Tab
              _buildContactsTab(context, safetyProvider),

              // History Tab
              _buildHistoryTab(context, safetyProvider),

              // Settings Tab
              _buildSettingsTab(context, safetyProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusTab(BuildContext context, SafetyProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Safety Mode Toggle
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Safety Mode',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Enable real-time safety alerts',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: provider.isSafetyModeEnabled,
                        onChanged: (value) {
                          provider.toggleSafetyMode(value);
                        },
                      ),
                    ],
                  ),
                  if (provider.isSafetyModeEnabled) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Safety Mode is active. You will receive alerts.',
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Safety Status Card
          if (provider.currentStatus != null)
            DetailedSafetyCard(
              status: provider.currentStatus!,
              rainMm: _rainMm,
              windSpeed: _windSpeed,
              visibility: _visibility,
              temperature: _temperature,
              humidity: _humidity,
            ),

          const SizedBox(height: 20),

          // Recommendations
          if (provider.currentStatus != null) ...[
            const Text(
              'Recommendations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...SafetyService.getRecommendations(provider.currentStatus!.level)
                .map(
              (rec) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.blue, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          rec,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactsTab(BuildContext context, SafetyProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Emergency Contacts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (provider.emergencyContacts.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.phone_disabled,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No emergency contacts',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...provider.emergencyContacts.map(
            (contact) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: EmergencyContactCard(
                contact: contact,
                onDelete: () {
                  provider.removeEmergencyContact(contact.id);
                },
              ),
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Show add contact dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add contact feature coming soon')),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Emergency Contact'),
        ),
      ],
    );
  }

  Widget _buildHistoryTab(BuildContext context, SafetyProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Safety History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (provider.safetyHistory.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No safety history yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          ...provider.safetyHistory.map(
            (alert) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SafetyHistoryCard(alert: alert),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              provider.clearSafetyHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared')),
              );
            },
            icon: const Icon(Icons.delete),
            label: const Text('Clear History'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSettingsTab(BuildContext context, SafetyProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weather Parameters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Rainfall slider
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rainfall',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_rainMm.toStringAsFixed(1)} mm',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _rainMm,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    onChanged: (value) {
                      setState(() => _rainMm = value);
                      _updateSafetyCheck();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Wind Speed slider
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Wind Speed',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_windSpeed.toStringAsFixed(1)} km/h',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.cyan,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _windSpeed,
                    min: 0,
                    max: 60,
                    divisions: 60,
                    onChanged: (value) {
                      setState(() => _windSpeed = value);
                      _updateSafetyCheck();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Visibility slider
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Visibility',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$_visibility m',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _visibility.toDouble(),
                    min: 0,
                    max: 10000,
                    divisions: 100,
                    onChanged: (value) {
                      setState(() => _visibility = value.toInt());
                      _updateSafetyCheck();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Temperature slider
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Temperature',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _temperature,
                    min: -20,
                    max: 50,
                    divisions: 70,
                    onChanged: (value) {
                      setState(() => _temperature = value);
                      _updateSafetyCheck();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Humidity slider
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Humidity',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$_humidity%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _humidity.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 100,
                    onChanged: (value) {
                      setState(() => _humidity = value.toInt());
                      _updateSafetyCheck();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
