import '../models/saftey_status.dart';
import '../models/emergency_contact.dart';
import 'location_service.dart';
import 'weather_services.dart';

class SafetyRecommendation {
  final String id;
  final String title;
  final String description;
  final String category;
  final int priority; // 1-5, 5 being highest
  final List<String> actions;
  final DateTime timestamp;
  final bool isEmergency;

  SafetyRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.actions,
    DateTime? timestamp,
    this.isEmergency = false,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'actions': actions,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isEmergency': isEmergency,
    };
  }

  factory SafetyRecommendation.fromJson(Map<String, dynamic> json) {
    return SafetyRecommendation(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      priority: json['priority'],
      actions: List<String>.from(json['actions']),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      isEmergency: json['isEmergency'] ?? false,
    );
  }
}

class SafetyRecommendationService {
  // Generate recommendations based on safety status and weather
  static Future<List<SafetyRecommendation>> generateRecommendations(
    SafetyStatus status,
    double lat,
    double lon,
    List<EmergencyContact> emergencyContacts,
  ) async {
    final recommendations = <SafetyRecommendation>[];

    // Weather-based recommendations
    recommendations
        .addAll(await _generateWeatherRecommendations(status, lat, lon));

    // Location-based recommendations
    recommendations.addAll(await _generateLocationRecommendations(lat, lon));

    // Emergency contact recommendations
    recommendations
        .addAll(_generateEmergencyContactRecommendations(emergencyContacts));

    // General safety recommendations
    recommendations.addAll(_generateGeneralSafetyRecommendations(status));

    // Sort by priority (highest first)
    recommendations.sort((a, b) => b.priority.compareTo(a.priority));

    return recommendations.take(10).toList(); // Return top 10 recommendations
  }

  // Generate weather-specific recommendations
  static Future<List<SafetyRecommendation>> _generateWeatherRecommendations(
    SafetyStatus status,
    double lat,
    double lon,
  ) async {
    final recommendations = <SafetyRecommendation>[];

    try {
      // Get current weather data
      final weatherData = await WeatherService.getCurrentWeather(lat, lon);
      if (weatherData == null) return recommendations;

      final rainMm = weatherData['rain']?['1h'] ?? 0.0;
      final windSpeed = weatherData['wind']?['speed'] ?? 0.0;
      final visibility = weatherData['visibility'] ?? 10000;
      final temperature = weatherData['main']?['temp'] ?? 25.0;
      final humidity = weatherData['main']?['humidity'] ?? 50;

      // Heavy rain recommendations
      if (rainMm > 10) {
        recommendations.add(SafetyRecommendation(
          id: 'heavy_rain_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Heavy Rainfall Warning',
          description:
              'Heavy rain detected. Take precautions to avoid flooding and slippery conditions.',
          category: 'Weather',
          priority: 4,
          actions: [
            'Avoid driving if possible',
            'Stay indoors if lightning is present',
            'Check for flood warnings in your area',
            'Keep emergency kit ready',
          ],
        ));
      }

      // High wind recommendations
      if (windSpeed > 15) {
        recommendations.add(SafetyRecommendation(
          id: 'high_wind_${DateTime.now().millisecondsSinceEpoch}',
          title: 'High Wind Advisory',
          description:
              'Strong winds detected. Secure loose objects and avoid outdoor activities.',
          category: 'Weather',
          priority: 4,
          actions: [
            'Secure outdoor furniture and objects',
            'Avoid construction areas with cranes',
            'Be cautious when driving',
            'Stay away from power lines',
          ],
        ));
      }

      // Poor visibility recommendations
      if (visibility < 1000) {
        recommendations.add(SafetyRecommendation(
          id: 'poor_visibility_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Reduced Visibility Alert',
          description:
              'Poor visibility conditions detected. Drive cautiously and use headlights.',
          category: 'Weather',
          priority: 3,
          actions: [
            'Use headlights even during daytime',
            'Increase following distance',
            'Avoid sudden lane changes',
            'Consider postponing travel if possible',
          ],
        ));
      }

      // Extreme temperature recommendations
      if (temperature > 35 || temperature < 0) {
        final isHot = temperature > 35;
        recommendations.add(SafetyRecommendation(
          id: 'extreme_temp_${DateTime.now().millisecondsSinceEpoch}',
          title: isHot ? 'Heat Wave Alert' : 'Extreme Cold Warning',
          description: isHot
              ? 'High temperatures detected. Stay hydrated and avoid prolonged sun exposure.'
              : 'Extreme cold temperatures detected. Dress warmly and avoid frostbite.',
          category: 'Weather',
          priority: 4,
          actions: isHot
              ? [
                  'Stay hydrated - drink plenty of water',
                  'Avoid outdoor activities during peak heat',
                  'Wear light, breathable clothing',
                  'Check on elderly neighbors',
                ]
              : [
                  'Dress in layers',
                  'Cover exposed skin',
                  'Limit time outdoors',
                  'Check on vulnerable individuals',
                ],
        ));
      }

      // High humidity recommendations
      if (humidity > 80) {
        recommendations.add(SafetyRecommendation(
          id: 'high_humidity_${DateTime.now().millisecondsSinceEpoch}',
          title: 'High Humidity Alert',
          description:
              'High humidity levels may cause discomfort and health issues.',
          category: 'Weather',
          priority: 2,
          actions: [
            'Stay in air-conditioned environments',
            'Drink plenty of fluids',
            'Avoid strenuous activities',
            'Monitor for heat-related symptoms',
          ],
        ));
      }
    } catch (e) {
      print('Error generating weather recommendations: $e');
    }

    return recommendations;
  }

  // Generate location-based recommendations
  static Future<List<SafetyRecommendation>> _generateLocationRecommendations(
    double lat,
    double lon,
  ) async {
    final recommendations = <SafetyRecommendation>[];

    try {
      // Get location details
      final locationData = await LocationService.getCurrentLocation();
      if (locationData == null) return recommendations;

      // Coastal area recommendations (simplified - in real app, use proper GIS data)
      final isCoastal = _isCoastalArea(lat, lon);
      if (isCoastal) {
        recommendations.add(SafetyRecommendation(
          id: 'coastal_area_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Coastal Area Safety',
          description:
              'You are in a coastal area. Be aware of tidal changes and storm surges.',
          category: 'Location',
          priority: 3,
          actions: [
            'Monitor tide schedules',
            'Avoid walking on wet sand during high tide',
            'Know evacuation routes',
            'Keep emergency supplies accessible',
          ],
        ));
      }

      // Urban area recommendations
      final isUrban = _isUrbanArea(lat, lon);
      if (isUrban) {
        recommendations.add(SafetyRecommendation(
          id: 'urban_safety_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Urban Area Awareness',
          description:
              'You are in an urban environment. Stay aware of your surroundings.',
          category: 'Location',
          priority: 2,
          actions: [
            'Keep valuables secure',
            'Be aware of traffic when crossing streets',
            'Stay in well-lit areas at night',
            'Keep emergency contacts updated',
          ],
        ));
      }

      // Remote area recommendations
      final isRemote = _isRemoteArea(lat, lon);
      if (isRemote) {
        recommendations.add(SafetyRecommendation(
          id: 'remote_area_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Remote Area Precautions',
          description:
              'You are in a remote area. Ensure you have adequate supplies and communication.',
          category: 'Location',
          priority: 4,
          actions: [
            'Carry extra water and food',
            'Ensure phone is charged',
            'Inform someone of your plans',
            'Carry emergency signaling device',
          ],
        ));
      }
    } catch (e) {
      print('Error generating location recommendations: $e');
    }

    return recommendations;
  }

  // Generate emergency contact recommendations
  static List<SafetyRecommendation> _generateEmergencyContactRecommendations(
    List<EmergencyContact> contacts,
  ) {
    final recommendations = <SafetyRecommendation>[];

    if (contacts.isEmpty) {
      recommendations.add(SafetyRecommendation(
        id: 'no_emergency_contacts_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Add Emergency Contacts',
        description:
            'You have no emergency contacts saved. Add trusted contacts for safety.',
        category: 'Emergency',
        priority: 5,
        actions: [
          'Add at least 2 emergency contacts',
          'Include family members and friends',
          'Add local emergency services',
          'Test contact information regularly',
        ],
      ));
    } else if (contacts.length < 2) {
      recommendations.add(SafetyRecommendation(
        id: 'few_emergency_contacts_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Add More Emergency Contacts',
        description:
            'Consider adding more emergency contacts for better safety coverage.',
        category: 'Emergency',
        priority: 3,
        actions: [
          'Add additional family members',
          'Include close friends',
          'Add workplace contacts',
          'Consider adding emergency services',
        ],
      ));
    }

    // Check for different types of contacts
    final hasPolice =
        contacts.any((c) => c.type == EmergencyContactType.police);
    final hasMedical =
        contacts.any((c) => c.type == EmergencyContactType.ambulance);

    if (!hasPolice) {
      recommendations.add(SafetyRecommendation(
        id: 'add_police_contact_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Add Police Contact',
        description: 'Consider adding local police contact for emergencies.',
        category: 'Emergency',
        priority: 3,
        actions: [
          'Find local police non-emergency number',
          'Add as emergency contact',
          'Test the contact number',
          'Keep updated with local changes',
        ],
      ));
    }

    if (!hasMedical) {
      recommendations.add(SafetyRecommendation(
        id: 'add_medical_contact_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Add Medical Contact',
        description:
            'Add medical emergency contact for health-related situations.',
        category: 'Emergency',
        priority: 3,
        actions: [
          'Add ambulance service number',
          'Include your doctor\'s contact',
          'Add hospital emergency number',
          'Consider adding poison control',
        ],
      ));
    }

    return recommendations;
  }

  // Generate general safety recommendations
  static List<SafetyRecommendation> _generateGeneralSafetyRecommendations(
    SafetyStatus status,
  ) {
    final recommendations = <SafetyRecommendation>[];

    // Battery level recommendations
    recommendations.add(SafetyRecommendation(
      id: 'battery_check_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Battery Level Check',
      description:
          'Ensure your device has sufficient battery for emergency situations.',
      category: 'Device',
      priority: 2,
      actions: [
        'Keep battery above 20%',
        'Carry portable charger',
        'Know location of power outlets',
        'Enable battery saver mode if needed',
      ],
    ));

    // Emergency kit recommendations
    recommendations.add(SafetyRecommendation(
      id: 'emergency_kit_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Emergency Kit Preparation',
      description: 'Prepare an emergency kit with essential supplies.',
      category: 'Preparation',
      priority: 2,
      actions: [
        'Include first aid supplies',
        'Pack water and non-perishable food',
        'Add flashlight and extra batteries',
        'Include important documents',
      ],
    ));

    // Communication recommendations
    recommendations.add(SafetyRecommendation(
      id: 'communication_backup_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Backup Communication',
      description: 'Ensure multiple ways to communicate in emergencies.',
      category: 'Communication',
      priority: 3,
      actions: [
        'Keep phone charged',
        'Have backup phone available',
        'Know payphone locations',
        'Learn emergency radio frequencies',
      ],
    ));

    return recommendations;
  }

  // Helper methods for location detection (simplified)
  static bool _isCoastalArea(double lat, double lon) {
    // Simplified coastal detection - in real app, use proper GIS/geospatial data
    // This is just a placeholder implementation
    return false; // Would need actual coastal boundary data
  }

  static bool _isUrbanArea(double lat, double lon) {
    // Simplified urban detection - in real app, use population density data
    // This is just a placeholder implementation
    return true; // Assume urban for now
  }

  static bool _isRemoteArea(double lat, double lon) {
    // Simplified remote area detection
    // This is just a placeholder implementation
    return false; // Would need actual remoteness calculation
  }

  // Get emergency actions for specific hazard level
  static List<String> getEmergencyActions(HazardLevel level) {
    switch (level) {
      case HazardLevel.danger:
        return [
          'Evacuate immediately to higher ground',
          'Call emergency services (911)',
          'Follow official evacuation orders',
          'Move to designated emergency shelter',
          'Avoid flooded areas and downed power lines',
        ];
      case HazardLevel.caution:
        return [
          'Prepare emergency kit',
          'Monitor weather updates',
          'Secure outdoor objects',
          'Stay alert for evacuation notices',
          'Contact emergency contacts',
        ];
      case HazardLevel.safe:
        return [
          'Stay indoors if possible',
          'Monitor weather conditions',
          'Prepare for possible evacuation',
          'Keep emergency supplies ready',
          'Stay informed through official channels',
        ];
    }
  }

  // Get location-specific emergency resources
  static Future<List<String>> getLocationEmergencyResources(
      double lat, double lon) async {
    // In a real implementation, this would query local emergency services
    // For now, return general emergency numbers
    return [
      'Emergency: 911',
      'Non-emergency police: Contact local authorities',
      'Fire department: Contact local fire services',
      'Medical emergency: 911',
      'Poison control: 1-800-222-1222 (US)',
    ];
  }
}
