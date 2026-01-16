import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'emergency_contacts.dart';
import 'sos_screen.dart';
import 'medication_tracker.dart';
import 'daily_activities.dart';
import 'family_contacts.dart';
import 'health_reminders.dart';
import 'nearby_services.dart';
import '../../Services/weather_services.dart';
import '../../Services/location_service.dart';

class CareDashboard extends StatefulWidget {
  const CareDashboard({super.key});

  @override
  State<CareDashboard> createState() => _CareDashboardState();
}

class _CareDashboardState extends State<CareDashboard> {
  String _weatherCondition = "Loading...";
  String _temperature = "--°C";
  String _safetyAlert = "All clear";
  Color _safetyColor = Colors.green;
  List<Map<String, dynamic>> _todayReminders = [];
  List<Map<String, dynamic>> _todayActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // Load weather data
      await _loadWeatherData();

      // Load today's reminders
      await _loadTodayReminders();

      // Load today's activities
      await _loadTodayActivities();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWeatherData() async {
    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        final weather = await WeatherService.getCurrentWeather(
            position.latitude, position.longitude);
        if (weather != null) {
          setState(() {
            _temperature = "${weather['main']['temp'].toStringAsFixed(1)}°C";
            _weatherCondition = weather['weather'][0]['description'];

            // Simple safety alert based on weather
            final temp = weather['main']['temp'];
            if (temp > 35) {
              _safetyAlert = "Heat Alert";
              _safetyColor = Colors.red;
            } else if (temp < 5) {
              _safetyAlert = "Cold Alert";
              _safetyColor = Colors.blue;
            } else {
              _safetyAlert = "Weather OK";
              _safetyColor = Colors.green;
            }
          });
        }
      }
    } catch (e) {
      print('Error loading weather: $e');
    }
  }

  Future<void> _loadTodayReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersData = prefs.getStringList('health_reminders') ?? [];

      final todayReminders = remindersData
          .map((reminderJson) {
            final parts = reminderJson.split('|');
            return {
              'title': parts[0],
              'time': parts[2],
              'completed': parts[5] == 'true',
              'enabled': parts[4] == 'true',
            };
          })
          .where((reminder) => reminder['enabled'] == true)
          .take(3) // Show only first 3
          .toList();

      setState(() {
        _todayReminders = todayReminders;
      });
    } catch (e) {
      print('Error loading reminders: $e');
    }
  }

  Future<void> _loadTodayActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final todayKey = '${now.year}-${now.month}-${now.day}';
      final activitiesData = prefs.getStringList('activities_$todayKey') ?? [];

      final todayActivities = activitiesData
          .map((activityJson) {
            final parts = activityJson.split('|');
            return {
              'name': parts[0],
              'completed': parts[5] == 'true',
            };
          })
          .take(3) // Show only first 3
          .toList();

      setState(() {
        _todayActivities = todayActivities;
      });
    } catch (e) {
      print('Error loading activities: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Care Dashboard'),
        backgroundColor: Colors.deepPurple.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weather & Safety Section
                    _buildWeatherSafetyCard(),

                    const SizedBox(height: 20),

                    // Quick Actions Grid
                    _buildQuickActionsGrid(),

                    const SizedBox(height: 20),

                    // Today's Health Summary
                    _buildHealthSummary(),

                    const SizedBox(height: 20),

                    // Voice Assistance Hints
                    _buildVoiceHints(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWeatherSafetyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _temperature,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _weatherCondition,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _safetyColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _safetyAlert == "All clear"
                          ? Icons.check_circle
                          : Icons.warning,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _safetyAlert,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            DateFormat('EEEE, MMM d').format(DateTime.now()),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildLargeActionCard(
              'SOS Emergency',
              Icons.warning,
              Colors.red,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SOSScreen()),
              ),
            ),
            _buildLargeActionCard(
              'Emergency Contacts',
              Icons.contacts,
              Colors.orange,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const EmergencyContactsScreen()),
              ),
            ),
            _buildLargeActionCard(
              'Health Reminders',
              Icons.health_and_safety,
              Colors.green,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const HealthRemindersScreen()),
              ),
            ),
            _buildLargeActionCard(
              'Medication Tracker',
              Icons.medication,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MedicationTrackerScreen()),
              ),
            ),
            _buildLargeActionCard(
              'Daily Activities',
              Icons.schedule,
              Colors.purple,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const DailyActivitiesScreen()),
              ),
            ),
            _buildLargeActionCard(
              'Nearby Services',
              Icons.location_on,
              Colors.teal,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NearbyServicesScreen()),
              ),
            ),
            _buildLargeActionCard(
              'Family Contacts',
              Icons.family_restroom,
              Colors.pink,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FamilyContactsScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLargeActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Health Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Reminders Section
          if (_todayReminders.isNotEmpty) ...[
            const Text(
              'Upcoming Reminders',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            ..._todayReminders.map((reminder) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: reminder['completed']
                        ? Colors.green.shade50
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: reminder['completed']
                          ? Colors.green.shade200
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        reminder['completed']
                            ? Icons.check_circle
                            : Icons.schedule,
                        color:
                            reminder['completed'] ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${reminder['title']} at ${reminder['time']}',
                          style: TextStyle(
                            decoration: reminder['completed']
                                ? TextDecoration.lineThrough
                                : null,
                            color: reminder['completed']
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],

          // Activities Section
          if (_todayActivities.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Daily Activities',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${_todayActivities.where((a) => a['completed']).length}/${_todayActivities.length}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'completed',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVoiceHints() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade100, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mic, color: Colors.purple.shade700),
              const SizedBox(width: 8),
              Text(
                'Voice Commands',
                style: TextStyle(
                  color: Colors.purple.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Try saying:\n'
            '• "Call emergency contact"\n'
            '• "Take my medication"\n'
            '• "Check my health reminders"\n'
            '• "Find nearby hospital"\n'
            '• "Share my location"',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
