import 'package:flutter/material.dart';
import '../../models/emergency_contact.dart';
import '../../Services/emergency_contact_service.dart';
import '../../Widgets/emergency_contact_card.dart';
import '../../popups/add_contact_dialog.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<EmergencyContact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final service = EmergencyContactService();
      final contacts = await service.loadAllEmergencyContacts();
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading contacts: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
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
            Icons.contacts,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Emergency Contacts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add emergency contacts for quick access',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addContact,
            icon: const Icon(Icons.add),
            label: const Text('Add Contact'),
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
        return EmergencyContactCard(
          contact: contact,
          onCall: () => _callContact(contact),
          onEdit: () => _editContact(contact),
          onDelete: () => _deleteContact(contact),
        );
      },
    );
  }

  void _addContact() {
    showDialog(
      context: context,
      builder: (context) => AddContactDialog(
        onContactAdded: _handleContactAdded,
      ),
    );
  }

  void _editContact(EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (context) => AddContactDialog(
        initialContact: contact,
        onContactAdded: _handleContactAdded,
      ),
    );
  }

  void _handleContactAdded(EmergencyContact contact) {
    // Save the contact using the service
    final service = EmergencyContactService();

    // Check if this is an update or add
    final existingContact = _contacts.firstWhere(
      (c) => c.id == contact.id,
      orElse: () => EmergencyContact(
        id: '',
        name: '',
        phoneNumber: '',
        email: '',
        type: EmergencyContactType.family,
      ),
    );

    final isUpdate = existingContact.id.isNotEmpty;

    (isUpdate
            ? service.updateEmergencyContact(contact)
            : service.addEmergencyContact(contact))
        .then((_) {
      _loadContacts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${contact.name} ${isUpdate ? 'updated' : 'added'} successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving contact: $error')),
      );
    });
  }

  Future<void> _deleteContact(EmergencyContact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
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
      try {
        final service = EmergencyContactService();
        await service.removeEmergencyContact(contact.id);
        _loadContacts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact deleted')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting contact: $e')),
        );
      }
    }
  }

  void _callContact(EmergencyContact contact) {
    // Implement call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling ${contact.name}...')),
    );
  }
}
