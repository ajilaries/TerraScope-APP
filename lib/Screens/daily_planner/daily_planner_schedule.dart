import 'package:flutter/material.dart';
import 'package:terra_scope_apk/Services/daily_planner_service.dart';
import 'package:terra_scope_apk/Services/local_notification_service.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class DailyPlannerSchedule extends StatefulWidget {
  const DailyPlannerSchedule({super.key});

  @override
  State<DailyPlannerSchedule> createState() => _DailyPlannerScheduleState();
}

class _DailyPlannerScheduleState extends State<DailyPlannerSchedule> {
  final DailyPlannerService _service = DailyPlannerService();
  List<Map<String, dynamic>> _schedules = [];
  bool _isLoading = true;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() => _isLoading = true);
    try {
      final schedules = await _service.getSchedules();
      final events = <DateTime, List<Map<String, dynamic>>>{};
      for (final schedule in schedules) {
        final date = DateTime.parse(schedule['date']);
        final dayKey = DateTime(date.year, date.month, date.day);
        if (events[dayKey] == null) {
          events[dayKey] = [];
        }
        events[dayKey]!.add(schedule);
      }
      setState(() {
        _schedules = schedules;
        _events = events;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading schedules: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addSchedule() async {
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
        title: const Text('Add Schedule'),
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
      final dateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      await _service.addSchedule({
        'title': titleController.text,
        'description': descriptionController.text,
        'date': dateTime.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Show notification that schedule was added
      await LocalNotificationService.showScheduleAddedNotification(
          titleController.text);

      // Schedule a reminder notification 15 minutes before the event
      await LocalNotificationService.scheduleScheduleReminder(
        scheduleId: dateTime.millisecondsSinceEpoch, // Use timestamp as ID
        title: titleController.text,
        description: descriptionController.text,
        scheduleDate: dateTime,
      );

      _loadSchedules();
    }
  }

  Future<void> _deleteSchedule(String scheduleId) async {
    await _service.deleteSchedule(scheduleId);
    _loadSchedules();
  }

  Future<void> _editSchedule(Map<String, dynamic> schedule) async {
    final dateTime = DateTime.parse(schedule['date']);
    final TextEditingController titleController =
        TextEditingController(text: schedule['title']);
    final TextEditingController descriptionController =
        TextEditingController(text: schedule['description'] ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Schedule'),
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
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      await _service.updateSchedule(schedule['id'], {
        'title': titleController.text,
        'description': descriptionController.text,
        'date': dateTime.toIso8601String(),
      });
      _loadSchedules();
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDaySchedules =
        _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        backgroundColor: Colors.teal.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addSchedule,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  eventLoader: _getEventsForDay,
                  onDaySelected: _onDaySelected,
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Colors.teal.shade700,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.teal.shade200,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Colors.teal.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: selectedDaySchedules.isEmpty
                      ? const Center(child: Text('No schedules for this day'))
                      : ListView.builder(
                          itemCount: selectedDaySchedules.length,
                          itemBuilder: (context, index) {
                            final schedule = selectedDaySchedules[index];
                            final dateTime = DateTime.parse(schedule['date']);
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: ListTile(
                                title: Text(schedule['title']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(schedule['description'] ?? ''),
                                    Text(
                                      DateFormat('hh:mm a').format(dateTime),
                                      style: TextStyle(
                                          color: Colors.teal.shade700),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () => _editSchedule(schedule),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _deleteSchedule(schedule['id']),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
