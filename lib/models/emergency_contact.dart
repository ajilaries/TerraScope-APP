enum EmergencyContactType { police, ambulance, fire, family, friend, custom }

class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String email;
  final EmergencyContactType type;
  final String? notes;
  bool isPrimary;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.type,
    this.notes,
    this.isPrimary = false,
  });

  String get icon {
    switch (type) {
      case EmergencyContactType.police:
        return '🚔';
      case EmergencyContactType.ambulance:
        return '🚑';
      case EmergencyContactType.fire:
        return '🚒';
      case EmergencyContactType.family:
        return '👨‍👩‍👧';
      case EmergencyContactType.friend:
        return '👥';
      case EmergencyContactType.custom:
        return '📞';
    }
  }
}
