import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/safety_provider.dart';
import '../../Services/saftey_service.dart';
import '../../models/saftey_status.dart';
import '../../Widgets/detailed_safety_card.dart';
import '../../Widgets/emergency_contact_card.dart';
import '../../Widgets/safety_history_card.dart';
import '../../popups/add_contact_dialog.dart';

class SafetyModeScreen extends StatefulWidget {
  const SafetyModeScreen({super.key});

  @override
  State<SafetyModeScreen> createState() => _SafetyModeScreenState();
}

class _SafetyModeScreenState extends State<SafetyModeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SafetyStatus? _previousStatus;

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
          // Check for status changes and show alerts
          if (safetyProvider.isSafetyModeEnabled &&
              safetyProvider.currentStatus != null &&
              _previousStatus != safetyProvider.currentStatus) {
            // Status has changed, show alert if it's not safe
            if (safetyProvider.currentStatus!.level != HazardLevel.safe) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                safetyProvider.showSafetyAlert(context);
              });
            }
            _previousStatus = safetyProvider.currentStatus;
          }

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
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
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
          if (provider.currentStatus != null &&
              provider.currentRainMm != null &&
              provider.currentWindSpeed != null &&
              provider.currentVisibility != null &&
              provider.currentTemperature != null &&
              provider.currentHumidity != null)
            DetailedSafetyCard(
              status: provider.currentStatus!,
              rainMm: provider.currentRainMm!,
              windSpeed: provider.currentWindSpeed!,
              visibility: provider.currentVisibility!,
              temperature: provider.currentTemperature!,
              humidity: provider.currentHumidity!,
            )
          else if (provider.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (provider.errorMessage != null)
            Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to load safety data',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.errorMessage!,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
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
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
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
                    color: Colors.grey.shade300,
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
            final screenContext = context; // Capture screen context
            showDialog(
              context: context,
              builder: (dialogContext) => AddContactDialog(
                onContactAdded: (contact) async {
                  try {
                    await provider.addEmergencyContact(contact);
                    if (mounted) {
                      ScaffoldMessenger.of(screenContext).showSnackBar(
                        SnackBar(content: Text('${contact.name} added to emergency contacts')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(screenContext).showSnackBar(
                        SnackBar(
                          content: Text('Failed to add emergency contact: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
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
                SnackBar(content: const Text('History cleared')),
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
            'Current Weather Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Refresh button
          ElevatedButton.icon(
            onPressed:
                provider.isLoading ? null : () => provider.checkCurrentSafety(),
            icon: provider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: Text(
                provider.isLoading ? 'Refreshing...' : 'Refresh Weather Data'),
          ),
          const SizedBox(height: 20),

          // Current weather parameters display
          if (provider.currentRainMm != null &&
              provider.currentWindSpeed != null &&
              provider.currentVisibility != null &&
              provider.currentTemperature != null &&
              provider.currentHumidity != null) ...[
            // Rainfall
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cloud_queue, color: Colors.blue),
                        const SizedBox(width: 12),
                        const Text(
                          'Rainfall',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      '${provider.currentRainMm!.toStringAsFixed(1)} mm',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Wind Speed
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.air, color: Colors.cyan),
                        const SizedBox(width: 12),
                        const Text(
                          'Wind Speed',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      '${provider.currentWindSpeed!.toStringAsFixed(1)} km/h',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.cyan,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Visibility
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.visibility, color: Colors.purple),
                        const SizedBox(width: 12),
                        const Text(
                          'Visibility',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      '${provider.currentVisibility!} m',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Temperature
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.thermostat, color: Colors.red),
                        const SizedBox(width: 12),
                        const Text(
                          'Temperature',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      '${provider.currentTemperature!.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Humidity
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.opacity, color: Colors.teal),
                        const SizedBox(width: 12),
                        const Text(
                          'Humidity',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      '${provider.currentHumidity!}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (provider.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (provider.errorMessage != null)
            Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to load weather data',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.errorMessage!,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.cloud_off, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No weather data available',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enable safety mode to load current weather data',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Safety settings
          const Text(
            'Safety Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Clear history button
          ElevatedButton.icon(
            onPressed: () {
              provider.clearSafetyHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('Safety history cleared')),
              );
            },
            icon: const Icon(Icons.delete),
            label: const Text('Clear Safety History'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
