import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class FamilyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String relationship;
  final String icon;

  FamilyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    required this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
      'icon': icon,
    };
  }

  factory FamilyContact.fromJson(Map<String, dynamic> json) {
    return FamilyContact(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      relationship: json['relationship'],
      icon: json['icon'],
    );
  }
}

class FamilyContactsScreen extends StatefulWidget {
  const FamilyContactsScreen({super.key});

  @override
  State<FamilyContactsScreen> createState() => _FamilyContactsScreenState();
}

class _FamilyContactsScreenState extends State<FamilyContactsScreen> {
  List<FamilyContact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsData = prefs.getStringList('family_contacts') ?? [];

      setState(() {
        _contacts = contactsData.map((contactJson) {
          final parts = contactJson.split('|');
          return FamilyContact(
            id: parts[0],
            name: parts[1],
            phoneNumber: parts[2],
            relationship: parts[3],
            icon: parts[4],
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading family contacts: $e');
    }
  }

  Future<void> _saveContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsData = _contacts
          .map((contact) =>
              '${contact.id}|${contact.name}|${contact.phoneNumber}|${contact.relationship}|${contact.icon}')
          .toList();

      await prefs.setStringList('family_contacts', contactsData);
    } catch (e) {
      debugPrint('Error saving family contacts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Contacts'),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
              ? _buildEmptyState()
              : _buildContactsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addContact,
        backgroundColor: Colors.deepPurple.shade700,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.family_restroom,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Family Contacts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add family contacts for easy communication',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addContact,
            icon: const Icon(Icons.add),
            label: const Text('Add Family Contact'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05),
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
                  color: Colors.deepPurple.shade100,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  contact.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      contact.relationship,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      contact.phoneNumber,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.call, color: Colors.green),
                    onPressed: () => _callContact(contact),
                  ),
                  IconButton(
                    icon: const Icon(Icons.message, color: Colors.blue),
                    onPressed: () => _messageContact(contact),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _editContact(index);
                          break;
                        case 'delete':
                          _deleteContact(index);
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
            ],
          ),
        );
      },
    );
  }

  void _addContact() {
    showDialog(
      context: context,
      builder: (context) => _AddContactDialog(
        onAdd: (name, phoneNumber, relationship, icon) {
          final newContact = FamilyContact(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            phoneNumber: phoneNumber,
            relationship: relationship,
            icon: icon,
          );
          setState(() {
            _contacts.add(newContact);
          });
          _saveContacts();
        },
      ),
    );
  }

  void _editContact(int index) {
    final contact = _contacts[index];
    showDialog(
      context: context,
      builder: (context) => _AddContactDialog(
        initialName: contact.name,
        initialPhoneNumber: contact.phoneNumber,
        initialRelationship: contact.relationship,
        initialIcon: contact.icon,
        onAdd: (name, phoneNumber, relationship, icon) {
          setState(() {
            _contacts[index] = FamilyContact(
              id: contact.id,
              name: name,
              phoneNumber: phoneNumber,
              relationship: relationship,
              icon: icon,
            );
          });
          _saveContacts();
        },
      ),
    );
  }

  Future<void> _deleteContact(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content:
            Text('Are you sure you want to delete ${_contacts[index].name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _contacts.removeAt(index);
      });
      _saveContacts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact deleted')),
        );
      }
    }
  }

  Future<void> _callContact(FamilyContact contact) async {
    final Uri launchUri = Uri(scheme: 'tel', path: contact.phoneNumber);
    try {
      await launchUrl(launchUri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not make call: $e')),
        );
      }
    }
  }

  Future<void> _messageContact(FamilyContact contact) async {
    final Uri smsUri = Uri(scheme: 'sms', path: contact.phoneNumber);
    try {
      await launchUrl(smsUri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send message: $e')),
        );
      }
    }
  }
}

class _AddContactDialog extends StatefulWidget {
  final String? initialName;
  final String? initialPhoneNumber;
  final String? initialRelationship;
  final String? initialIcon;
  final Function(
      String name, String phoneNumber, String relationship, String icon) onAdd;

  const _AddContactDialog({
    this.initialName,
    this.initialPhoneNumber,
    this.initialRelationship,
    this.initialIcon,
    required this.onAdd,
  });

  @override
  State<_AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<_AddContactDialog> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _relationshipController;
  String _selectedIcon = '👨';

  final List<String> _icons = [
    '👨',
    '👩',
    '👴',
    '👵',
    '👦',
    '👧',
    '👨‍👩‍👧',
    '👨‍👩‍👦‍👦'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _phoneController =
        TextEditingController(text: widget.initialPhoneNumber ?? '');
    _relationshipController =
        TextEditingController(text: widget.initialRelationship ?? '');
    _selectedIcon = widget.initialIcon ?? '👨';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.initialName == null ? 'Add Family Contact' : 'Edit Contact'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter full name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+1 234 567 8900',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _relationshipController,
              decoration: const InputDecoration(
                labelText: 'Relationship',
                hintText: 'e.g., Father, Mother, Son',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Choose Icon:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _icons.map((icon) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = icon;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedIcon == icon
                            ? Colors.deepPurple
                            : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(icon, style: const TextStyle(fontSize: 24)),
                  ),
                );
              }).toList(),
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
                _phoneController.text.isNotEmpty &&
                _relationshipController.text.isNotEmpty) {
              widget.onAdd(
                _nameController.text,
                _phoneController.text,
                _relationshipController.text,
                _selectedIcon,
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
