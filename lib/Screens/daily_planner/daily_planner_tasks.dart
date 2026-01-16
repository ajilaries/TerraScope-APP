import 'package:flutter/material.dart';
import 'package:terra_scope_apk/Services/daily_planner_service.dart';

class DailyPlannerTasks extends StatefulWidget {
  const DailyPlannerTasks({super.key});

  @override
  State<DailyPlannerTasks> createState() => _DailyPlannerTasksState();
}

class _DailyPlannerTasksState extends State<DailyPlannerTasks> {
  final DailyPlannerService _service = DailyPlannerService();
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await _service.getTasks();
      setState(() => _tasks = tasks);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading tasks: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addTask() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
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
      await _service.addTask({
        'title': titleController.text,
        'description': descriptionController.text,
        'isCompleted': false,
        'createdAt': DateTime.now().toIso8601String(),
      });

      _loadTasks();
    }
  }

  Future<void> _toggleTaskCompletion(String taskId, bool isCompleted) async {
    await _service.updateTask(taskId, {'isCompleted': !isCompleted});
    _loadTasks();
  }

  Future<void> _deleteTask(String taskId) async {
    await _service.deleteTask(taskId);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: Colors.teal.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addTask,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(child: Text('No tasks yet. Add one!'))
              : ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          task['title'],
                          style: TextStyle(
                            decoration: task['isCompleted']
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Text(task['description'] ?? ''),
                        leading: Checkbox(
                          value: task['isCompleted'] ?? false,
                          onChanged: (value) =>
                              _toggleTaskCompletion(task['id'], task['isCompleted']),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTask(task['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
