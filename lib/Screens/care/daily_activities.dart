import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyActivitiesScreen extends StatefulWidget {
  const DailyActivitiesScreen({super.key});

  @override
  State<DailyActivitiesScreen> createState() => _DailyActivitiesScreenState();
}

class _DailyActivitiesScreenState extends State<DailyActivitiesScreen> {
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _defaultActivities = [
    {
      'name': 'Morning Walk',
      'icon': Icons.directions_walk,
      'color': Colors.green,
      'duration': '30 min',
      'completed': false,
    },
    {
      'name': 'Read Book',
      'icon': Icons.book,
      'color': Colors.blue,
      'duration': '20 min',
      'completed': false,
    },
    {
      'name': 'Meditation',
      'icon': Icons.self_improvement,
      'color': Colors.purple,
      'duration': '10 min',
      'completed': false,
    },
    {
      'name': 'Call Family',
      'icon': Icons.phone,
      'color': Colors.orange,
      'duration': '15 min',
      'completed': false,
    },
    {
      'name': 'Light Exercise',
      'icon': Icons.fitness_center,
      'color': Colors.red,
      'duration': '20 min',
      'completed': false,
    },
    {
      'name': 'Gardening',
      'icon': Icons.grass,
      'color': Colors.brown,
      'duration': '30 min',
      'completed': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final todayKey = '${now.year}-${now.month}-${now.day}';

      final savedActivities = prefs.getStringList('activities_$todayKey');
      if (savedActivities != null && savedActivities.isNotEmpty) {
        setState(() {
          _activities = savedActivities.map((activityJson) {
            final parts = activityJson.split('|');
            return {
              'name': parts[0],
              'icon':
                  IconData(int.parse(parts[1]), fontFamily: 'MaterialIcons'),
              'color': Color(int.parse(parts[2])),
              'duration': parts[3],
              'completed': parts[4] == 'true',
            };
          }).toList();
        });
      } else {
        // Load default activities for first time
        setState(() {
          _activities = List.from(_defaultActivities);
        });
        _saveActivities();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading activities: $e');
    }
  }

  Future<void> _saveActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final todayKey = '${now.year}-${now.month}-${now.day}';

      final activitiesData = _activities
          .map((activity) =>
              '${activity['name']}|${(activity['icon'] as IconData).codePoint}|${(activity['color'] as Color).value}|${activity['duration']}|${activity['completed']}')
          .toList();

      await prefs.setStringList('activities_$todayKey', activitiesData);
    } catch (e) {
      print('Error saving activities: $e');
    }
  }

  void _toggleActivity(int index) {
    setState(() {
      _activities[index]['completed'] = !_activities[index]['completed'];
    });
    _saveActivities();
  }

  void _addCustomActivity() {
    showDialog(
      context: context,
      builder: (context) => _AddActivityDialog(
        onAdd: (name, duration) {
          setState(() {
            _activities.add({
              'name': name,
              'icon': Icons.star,
              'color': Colors.indigo,
              'duration': duration,
              'completed': false,
            });
          });
          _saveActivities();
        },
      ),
    );
  }

  int _getCompletedCount() {
    return _activities
        .where((activity) => activity['completed'] == true)
        .length;
  }

  double _getCompletionPercentage() {
    if (_activities.isEmpty) return 0.0;
    return _getCompletedCount() / _activities.length;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Daily Activities'),
          backgroundColor: Colors.deepPurple.shade700,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Activities'),
        backgroundColor: Colors.deepPurple.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addCustomActivity,
            tooltip: 'Add Custom Activity',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Overview
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Today\'s Progress',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: _getCompletionPercentage(),
                          strokeWidth: 10,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getCompletionPercentage() >= 1.0
                                ? Colors.green
                                : Colors.deepPurple,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_getCompletedCount()}/${_activities.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'completed',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_getCompletionPercentage() >= 1.0)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.celebration, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'All activities completed! 🎉',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Activities List
            const Text(
              'Activities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ..._activities.map((activity) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: activity['completed']
                        ? Colors.green.shade50
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: activity['completed']
                          ? Colors.green.shade200
                          : Colors.grey.shade200,
                    ),
                    boxShadow: activity['completed']
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (activity['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          activity['icon'] as IconData,
                          color: activity['color'] as Color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity['name'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                decoration: activity['completed']
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: activity['completed']
                                    ? Colors.grey.shade600
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activity['duration'],
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: activity['completed'],
                        onChanged: (value) {
                          final index = _activities.indexOf(activity);
                          _toggleActivity(index);
                        },
                        activeColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 24),

            // Motivational Message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.deepPurple.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Daily Wellness Tips',
                        style: TextStyle(
                          color: Colors.deepPurple.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Start your day with a positive affirmation\n'
                    '• Take short breaks between activities\n'
                    '• Stay hydrated throughout the day\n'
                    '• Connect with loved ones regularly\n'
                    '• End your day with gratitude',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddActivityDialog extends StatefulWidget {
  final Function(String name, String duration) onAdd;

  const _AddActivityDialog({required this.onAdd});

  @override
  State<_AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<_AddActivityDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Custom Activity'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Activity Name',
              hintText: 'e.g., Yoga Practice',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _durationController,
            decoration: const InputDecoration(
              labelText: 'Duration',
              hintText: 'e.g., 15 min',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty &&
                _durationController.text.isNotEmpty) {
              widget.onAdd(_nameController.text, _durationController.text);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
