import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicationTrackerScreen extends StatefulWidget {
  const MedicationTrackerScreen({super.key});

  @override
  State<MedicationTrackerScreen> createState() =>
      _MedicationTrackerScreenState();
}

class _MedicationTrackerScreenState extends State<MedicationTrackerScreen> {
  List<Map<String, dynamic>> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medicationsData = prefs.getStringList('medications') ?? [];

      setState(() {
        _medications = medicationsData.map((medicationJson) {
          final parts = medicationJson.split('|');
          return {
            'name': parts[0],
            'dosage': parts[1],
            'frequency': parts[2],
            'times': parts
                .sublist(3)
                .map((time) => {'time': time, 'taken': false})
                .toList(),
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading medications: $e');
    }
  }

  Future<void> _saveMedications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medicationsData = _medications.map((medication) {
        final times =
            (medication['times'] as List).map((time) => time['time']).join('|');
        return '${medication['name']}|${medication['dosage']}|${medication['frequency']}|$times';
      }).toList();

      await prefs.setStringList('medications', medicationsData);
    } catch (e) {
      print('Error saving medications: $e');
    }
  }

  void _toggleMedicationTaken(int medicationIndex, int timeIndex) {
    setState(() {
      _medications[medicationIndex]['times'][timeIndex]['taken'] =
          !_medications[medicationIndex]['times'][timeIndex]['taken'];
    });
    _saveMedications();
  }

  void _addMedication() {
    showDialog(
      context: context,
      builder: (context) => _AddMedicationDialog(
        onAdd: (name, dosage, frequency, times) {
          setState(() {
            _medications.add({
              'name': name,
              'dosage': dosage,
              'frequency': frequency,
              'times':
                  times.map((time) => {'time': time, 'taken': false}).toList(),
            });
          });
          _saveMedications();
        },
      ),
    );
  }

  void _editMedication(int index) {
    final medication = _medications[index];
    showDialog(
      context: context,
      builder: (context) => _AddMedicationDialog(
        initialName: medication['name'],
        initialDosage: medication['dosage'],
        initialFrequency: medication['frequency'],
        initialTimes: (medication['times'] as List)
            .map((t) => t['time'] as String)
            .toList(),
        onAdd: (name, dosage, frequency, times) {
          setState(() {
            _medications[index] = {
              'name': name,
              'dosage': dosage,
              'frequency': frequency,
              'times':
                  times.map((time) => {'time': time, 'taken': false}).toList(),
            };
          });
          _saveMedications();
        },
      ),
    );
  }

  void _deleteMedication(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medication'),
        content: Text(
            'Are you sure you want to delete "${_medications[index]['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _medications.removeAt(index);
              });
              _saveMedications();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Tracker'),
        backgroundColor: Colors.deepPurple.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addMedication,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _medications.isEmpty
              ? _buildEmptyState()
              : _buildMedicationsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Medications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your medications to track them',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addMedication,
            icon: const Icon(Icons.add),
            label: const Text('Add Medication'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _medications.length,
      itemBuilder: (context, medicationIndex) {
        final medication = _medications[medicationIndex];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${medication['dosage']} - ${medication['frequency']}',
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
                          _editMedication(medicationIndex);
                          break;
                        case 'delete':
                          _deleteMedication(medicationIndex);
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
              const SizedBox(height: 16),
              const Text(
                'Today\'s Schedule',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...(medication['times'] as List).asMap().entries.map((timeEntry) {
                final timeIndex = timeEntry.key;
                final timeData = timeEntry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: timeData['taken']
                        ? Colors.green.shade50
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: timeData['taken']
                          ? Colors.green.shade200
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        timeData['time'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: timeData['taken']
                              ? Colors.green.shade700
                              : Colors.black,
                        ),
                      ),
                      Row(
                        children: [
                          if (timeData['taken'])
                            const Icon(Icons.check_circle, color: Colors.green),
                          Checkbox(
                            value: timeData['taken'],
                            onChanged: (value) => _toggleMedicationTaken(
                                medicationIndex, timeIndex),
                            activeColor: Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _AddMedicationDialog extends StatefulWidget {
  final String? initialName;
  final String? initialDosage;
  final String? initialFrequency;
  final List<String>? initialTimes;
  final Function(
      String name, String dosage, String frequency, List<String> times) onAdd;

  const _AddMedicationDialog({
    this.initialName,
    this.initialDosage,
    this.initialFrequency,
    this.initialTimes,
    required this.onAdd,
  });

  @override
  State<_AddMedicationDialog> createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends State<_AddMedicationDialog> {
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  String _selectedFrequency = 'Daily';
  List<String> _times = ['09:00 AM'];

  final List<String> _frequencies = [
    'Daily',
    'Twice Daily',
    'Three Times Daily',
    'Weekly',
    'As Needed'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _dosageController = TextEditingController(text: widget.initialDosage ?? '');
    _selectedFrequency = widget.initialFrequency ?? 'Daily';
    _times = widget.initialTimes ?? ['09:00 AM'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  void _addTime() {
    setState(() {
      _times.add('09:00 AM');
    });
  }

  void _removeTime(int index) {
    if (_times.length > 1) {
      setState(() {
        _times.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.initialName == null ? 'Add Medication' : 'Edit Medication'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Medication Name',
                hintText: 'e.g., Aspirin',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosage',
                hintText: 'e.g., 100mg',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedFrequency,
              decoration: const InputDecoration(labelText: 'Frequency'),
              items: _frequencies.map((frequency) {
                return DropdownMenuItem(
                  value: frequency,
                  child: Text(frequency),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFrequency = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Times to take:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ..._times.asMap().entries.map((entry) {
              final index = entry.key;
              final time = entry.value;
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: time),
                      decoration: InputDecoration(
                        labelText: 'Time ${index + 1}',
                        hintText: 'e.g., 09:00 AM',
                      ),
                      onChanged: (value) {
                        _times[index] = value;
                      },
                    ),
                  ),
                  if (_times.length > 1)
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeTime(index),
                    ),
                ],
              );
            }),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _addTime,
              icon: const Icon(Icons.add),
              label: const Text('Add Time'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade100,
                foregroundColor: Colors.deepPurple,
              ),
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
            if (_nameController.text.isNotEmpty &&
                _dosageController.text.isNotEmpty) {
              widget.onAdd(
                _nameController.text,
                _dosageController.text,
                _selectedFrequency,
                _times,
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
