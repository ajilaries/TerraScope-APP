import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthRemindersScreen extends StatefulWidget {
  const HealthRemindersScreen({super.key});

  @override
  State<HealthRemindersScreen> createState() => _HealthRemindersScreenState();
}

class _HealthRemindersScreenState extends State<HealthRemindersScreen> {
  List<Map<String, dynamic>> _reminders = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _defaultReminders = [
    {
      'title': 'Take Medication',
      'description': 'Time for your daily medication',
      'time': '09:00 AM',
      'type': 'medication',
      'enabled': true,
      'completed': false,
    },
    {
      'title': 'Drink Water',
      'description': 'Stay hydrated - drink a glass of water',
      'time': '10:00 AM',
      'type': 'hydration',
      'enabled': true,
      'completed': false,
    },
    {
      'title': 'Blood Pressure Check',
      'description': 'Monitor your blood pressure',
      'time': '08:00 AM',
      'type': 'health_check',
      'enabled': true,
      'completed': false,
    },
    {
      'title': 'Light Exercise',
      'description': 'Take a short walk or do light exercises',
      'time': '02:00 PM',
      'type': 'exercise',
      'enabled': true,
      'completed': false,
    },
    {
      'title': 'Evening Medication',
      'description': 'Time for your evening medication',
      'time': '08:00 PM',
      'type': 'medication',
      'enabled': true,
      'completed': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedReminders = prefs.getStringList('health_reminders');

      if (savedReminders != null && savedReminders.isNotEmpty) {
        setState(() {
          _reminders = savedReminders.map((reminderJson) {
            final parts = reminderJson.split('|');
            return {
              'title': parts[0],
              'description': parts[1],
              'time': parts[2],
              'type': parts[3],
              'enabled': parts[4] == 'true',
              'completed': parts[5] == 'true',
            };
          }).toList();
        });
      } else {
        // Load default reminders
        setState(() {
          _reminders = List.from(_defaultReminders);
        });
        _saveReminders();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading reminders: $e');
    }
  }

  Future<void> _saveReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersData = _reminders
          .map((reminder) =>
              '${reminder['title']}|${reminder['description']}|${reminder['time']}|${reminder['type']}|${reminder['enabled']}|${reminder['completed']}')
          .toList();

      await prefs.setStringList('health_reminders', remindersData);
    } catch (e) {
      print('Error saving reminders: $e');
    }
  }

  void _toggleReminder(int index) {
    setState(() {
      _reminders[index]['enabled'] = !_reminders[index]['enabled'];
    });
    _saveReminders();
  }

  void _markCompleted(int index) {
    setState(() {
      _reminders[index]['completed'] = !_reminders[index]['completed'];
    });
    _saveReminders();
  }

  void _addCustomReminder() {
    showDialog(
      context: context,
      builder: (context) => _AddReminderDialog(
        onAdd: (title, description, time, type) {
          setState(() {
            _reminders.add({
              'title': title,
              'description': description,
              'time': time,
              'type': type,
              'enabled': true,
              'completed': false,
            });
          });
          _saveReminders();
        },
      ),
    );
  }

  void _editReminder(int index) {
    final reminder = _reminders[index];
    showDialog(
      context: context,
      builder: (context) => _AddReminderDialog(
        initialTitle: reminder['title'],
        initialDescription: reminder['description'],
        initialTime: reminder['time'],
        initialType: reminder['type'],
        onAdd: (title, description, time, type) {
          setState(() {
            _reminders[index] = {
              'title': title,
              'description': description,
              'time': time,
              'type': type,
              'enabled': reminder['enabled'],
              'completed': reminder['completed'],
            };
          });
          _saveReminders();
        },
      ),
    );
  }

  void _deleteReminder(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text(
            'Are you sure you want to delete "${_reminders[index]['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _reminders.removeAt(index);
              });
              _saveReminders();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getReminderIcon(String type) {
    switch (type) {
      case 'medication':
        return Icons.medication;
      case 'hydration':
        return Icons.water_drop;
      case 'exercise':
        return Icons.fitness_center;
      case 'health_check':
        return Icons.monitor_heart;
      default:
        return Icons.notifications;
    }
  }

  Color _getReminderColor(String type) {
    switch (type) {
      case 'medication':
        return Colors.blue;
      case 'hydration':
        return Colors.cyan;
      case 'exercise':
        return Colors.green;
      case 'health_check':
        return Colors.red;
      default:
        return Colors.deepPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Health Reminders'),
          backgroundColor: Colors.deepPurple.shade700,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Reminders'),
        backgroundColor: Colors.deepPurple.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addCustomReminder,
            tooltip: 'Add Custom Reminder',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Summary
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
                    'Today\'s Health Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _summaryItem(
                        'Active',
                        _reminders
                            .where((r) => r['enabled'] == true)
                            .length
                            .toString(),
                        Colors.green,
                      ),
                      _summaryItem(
                        'Completed',
                        _reminders
                            .where((r) => r['completed'] == true)
                            .length
                            .toString(),
                        Colors.blue,
                      ),
                      _summaryItem(
                        'Pending',
                        _reminders
                            .where((r) =>
                                r['enabled'] == true && r['completed'] == false)
                            .length
                            .toString(),
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Reminders List
            const Text(
              'Reminders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ..._reminders.map((reminder) {
              final index = _reminders.indexOf(reminder);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      reminder['enabled'] ? Colors.white : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: reminder['enabled']
                        ? Colors.grey.shade200
                        : Colors.grey.shade300,
                  ),
                  boxShadow: reminder['enabled']
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getReminderColor(reminder['type'])
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getReminderIcon(reminder['type']),
                            color: _getReminderColor(reminder['type']),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reminder['title'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  decoration: reminder['completed']
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: reminder['completed']
                                      ? Colors.grey.shade600
                                      : Colors.black,
                                ),
                              ),
                              Text(
                                reminder['time'],
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                _editReminder(index);
                                break;
                              case 'delete':
                                _deleteReminder(index);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reminder['description'],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('Enabled:'),
                            Switch(
                              value: reminder['enabled'],
                              onChanged: (value) => _toggleReminder(index),
                              activeColor: Colors.deepPurple,
                            ),
                          ],
                        ),
                        if (reminder['enabled'])
                          ElevatedButton.icon(
                            onPressed: () => _markCompleted(index),
                            icon: Icon(
                              reminder['completed'] ? Icons.undo : Icons.check,
                              size: 16,
                            ),
                            label: Text(
                                reminder['completed'] ? 'Undo' : 'Mark Done'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: reminder['completed']
                                  ? Colors.grey
                                  : Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // Health Tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.lightBlue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.health_and_safety,
                          color: Colors.lightBlue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Health Tips',
                        style: TextStyle(
                          color: Colors.lightBlue.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Take medications at the same time each day\n'
                    '• Stay hydrated by drinking water regularly\n'
                    '• Keep track of your vital signs\n'
                    '• Exercise regularly, even if it\'s just walking\n'
                    '• Eat balanced meals and maintain healthy habits',
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

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _AddReminderDialog extends StatefulWidget {
  final String? initialTitle;
  final String? initialDescription;
  final String? initialTime;
  final String? initialType;
  final Function(String title, String description, String time, String type)
      onAdd;

  const _AddReminderDialog({
    this.initialTitle,
    this.initialDescription,
    this.initialTime,
    this.initialType,
    required this.onAdd,
  });

  @override
  State<_AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<_AddReminderDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _timeController;
  String _selectedType = 'medication';

  final List<String> _reminderTypes = [
    'medication',
    'hydration',
    'exercise',
    'health_check',
    'other'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _descriptionController =
        TextEditingController(text: widget.initialDescription ?? '');
    _timeController =
        TextEditingController(text: widget.initialTime ?? '09:00 AM');
    _selectedType = widget.initialType ?? 'medication';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialTitle == null
          ? 'Add Health Reminder'
          : 'Edit Reminder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Reminder Title',
                hintText: 'e.g., Take Medication',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Additional details about the reminder',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: 'Time',
                hintText: 'e.g., 09:00 AM',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: _reminderTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.replaceAll('_', ' ').toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty &&
                _descriptionController.text.isNotEmpty &&
                _timeController.text.isNotEmpty) {
              widget.onAdd(
                _titleController.text,
                _descriptionController.text,
                _timeController.text,
                _selectedType,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
