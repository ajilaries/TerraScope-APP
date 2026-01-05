import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emergency_provider.dart';
import '../models/emergency_contact.dart';
import '../Widgets/emergency_contact_card.dart';
import '../popups/add_contact_dialog.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  @override
  void initState() {
    super.initState();
    // Load contacts when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmergencyProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddContactDialog,
            tooltip: 'Add Emergency Contact',
          ),
        ],
      ),
      body: Consumer<EmergencyProvider>(
        builder: (context, emergencyProvider, child) {
          final contacts = emergencyProvider.contacts;

          if (contacts.isEmpty) {
            return _buildEmptyState();
          }

          return _buildContactsList(contacts, emergencyProvider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactDialog,
        tooltip: 'Add Emergency Contact',
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
            Icons.contact_emergency_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No Emergency Contacts',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add trusted contacts for emergency situations',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _showAddContactDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add First Contact'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList(
      List<EmergencyContact> contacts, EmergencyProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: EmergencyContactCard(
            contact: contact,
            onCall: () => _callContact(contact, provider),
            onMessage: () => _messageContact(contact, provider),
            onEdit: () => _editContact(contact),
            onDelete: () => _deleteContact(contact, provider),
            onSetPrimary:
                index > 0 ? () => _setPrimaryContact(contact, provider) : null,
          ),
        );
      },
    );
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AddContactDialog(
        onContactAdded: (contact) async {
          try {
            await context.read<EmergencyProvider>().addContact(contact);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${contact.name} added to emergency contacts'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error adding contact: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _callContact(
      EmergencyContact contact, EmergencyProvider provider) async {
    try {
      await provider.callContact(contact.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not make call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _messageContact(
      EmergencyContact contact, EmergencyProvider provider) async {
    final messageController = TextEditingController(
      text:
          '🚨 EMERGENCY ALERT 🚨\n\nI need help! Please contact me immediately.\n\nSent from TerraScope Safety Mode',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Emergency SMS to ${contact.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Emergency message',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Send Alert'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await provider.sendEmergencySMS(contact.id, messageController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Emergency SMS sent'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not send SMS: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _editContact(EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (dialogContext) => AddContactDialog(
        initialContact: contact,
        onContactAdded: (updatedContact) async {
          try {
            await context.read<EmergencyProvider>().updateContact(
                  contact.id,
                  updatedContact,
                );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contact updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error updating contact: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _deleteContact(
      EmergencyContact contact, EmergencyProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Emergency Contact'),
        content: Text(
            'Are you sure you want to remove ${contact.name} from your emergency contacts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await provider.removeContact(contact.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${contact.name} removed from emergency contacts'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error removing contact: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _setPrimaryContact(
      EmergencyContact contact, EmergencyProvider provider) async {
    try {
      await provider.setPrimaryContact(contact.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${contact.name} set as primary emergency contact'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting primary contact: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
