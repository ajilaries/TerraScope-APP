import 'package:flutter/material.dart';
import 'package:terra_scope_apk/Services/daily_planner_service.dart';
import 'package:intl/intl.dart';

class DailyPlannerReminders extends StatefulWidget {
  const DailyPlannerReminders({super.key});

  @override
  State<DailyPlannerReminders> createState() => _DailyPlannerRemindersState();
}

class _DailyPlannerRemindersState extends State<DailyPlannerReminders> {
  final DailyPlannerService _service = DailyPlannerService();
  List<Map<String, dynamic>> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }



  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    try {
      final reminders = await _service.getReminders();
      setState(() => _reminders = reminders);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading reminders: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addReminder() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate == null) return;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null) return;

    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      final reminderTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      await _service.addReminder({
        'title': titleController.text,
        'description': descriptionController.text,
        'reminderTime': reminderTime.toIso8601String(),
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      });

      _loadReminders();
    }
  }



  Future<void> _deleteReminder(String reminderId) async {
    await _service.deleteReminder(reminderId);
    _loadReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        backgroundColor: Colors.teal.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addReminder,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? const Center(child: Text('No reminders yet. Add one!'))
              : ListView.builder(
                  itemCount: _reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = _reminders[index];
                    final reminderTime =
                        DateTime.parse(reminder['reminderTime']);
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(reminder['title']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(reminder['description'] ?? ''),
                            Text(
                              DateFormat('MMM dd, yyyy hh:mm a')
                                  .format(reminderTime),
                              style: TextStyle(color: Colors.teal.shade700),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteReminder(reminder['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
