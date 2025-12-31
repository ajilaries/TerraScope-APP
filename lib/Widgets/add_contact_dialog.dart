import 'package:flutter/material.dart';
import '../models/emergency_contact.dart';

class AddContactDialog extends StatefulWidget {
  final EmergencyContact? initialContact;
  final Function(EmergencyContact) onContactAdded;

  const AddContactDialog({
    super.key,
    this.initialContact,
    required this.onContactAdded,
  });

  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  EmergencyContactType _selectedType = EmergencyContactType.custom;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialContact != null) {
      _nameController.text = widget.initialContact!.name;
      _phoneController.text = widget.initialContact!.phoneNumber;
      _emailController.text = widget.initialContact!.email;
      _selectedType = widget.initialContact!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialContact != null;

    return AlertDialog(
      title:
          Text(isEditing ? 'Edit Emergency Contact' : 'Add Emergency Contact'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  hintText: 'Enter contact name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  hintText: '+1 (555) 123-4567',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  // Basic phone number validation
                  final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
                  if (!phoneRegex
                      .hasMatch(value.replaceAll(RegExp(r'\s+'), ''))) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  hintText: 'contact@example.com',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final emailRegex =
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<EmergencyContactType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Contact Type',
                  border: OutlineInputBorder(),
                ),
                items: EmergencyContactType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(_getTypeIcon(type), size: 20),
                        const SizedBox(width: 8),
                        Text(_getTypeDisplayName(type)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveContact,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Update' : 'Add Contact'),
        ),
      ],
    );
  }

  void _saveContact() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final contact = EmergencyContact(
        id: widget.initialContact?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        type: _selectedType,
      );

      widget.onContactAdded(contact);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving contact: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  IconData _getTypeIcon(EmergencyContactType type) {
    switch (type) {
      case EmergencyContactType.police:
        return Icons.local_police;
      case EmergencyContactType.fire:
        return Icons.local_fire_department;
      case EmergencyContactType.ambulance:
        return Icons.local_hospital;
      case EmergencyContactType.family:
        return Icons.family_restroom;
      case EmergencyContactType.friend:
        return Icons.people;
      case EmergencyContactType.work:
        return Icons.work;
      case EmergencyContactType.custom:
        return Icons.contact_emergency;
    }
  }

  String _getTypeDisplayName(EmergencyContactType type) {
    switch (type) {
      case EmergencyContactType.police:
        return 'Police';
      case EmergencyContactType.fire:
        return 'Fire Department';
      case EmergencyContactType.ambulance:
        return 'Medical/Ambulance';
      case EmergencyContactType.family:
        return 'Family Member';
      case EmergencyContactType.friend:
        return 'Friend';
      case EmergencyContactType.work:
        return 'Work Colleague';
      case EmergencyContactType.custom:
        return 'Other';
    }
  }
}
