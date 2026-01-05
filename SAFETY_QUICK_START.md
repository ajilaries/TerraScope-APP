# Safety Mode - Quick Start Guide

## 🚀 Getting Started (2 Minutes)

### Step 1: Import SafetyProvider

The SafetyProvider is already integrated into `main.dart`. No additional setup needed! ✅

### Step 2: Access Safety Features

#### From Any Screen

```dart
// Navigate to Safety Mode Screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const SafetyModeScreen()),
);

// Navigate to SOS Screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const SOSScreen()),
);
```

#### From Provider

```dart
final safetyProvider = context.read<SafetyProvider>();

// Check current safety status
final status = safetyProvider.currentStatus;

// Get safety score (0-100)
final score = safetyProvider.getSafetyScore();

// Check if enabled
final isEnabled = safetyProvider.isSafetyModeEnabled;
```

---

## 📱 Main Tabs Explained

### 1️⃣ Status Tab

- **What**: Real-time safety status
- **Features**: Toggle, Status card, Recommendations
- **Action**: Enable safety mode, view current conditions

### 2️⃣ Contacts Tab

- **What**: Emergency contact management
- **Features**: View contacts, Quick call, Add/Remove
- **Action**: Manage emergency services

### 3️⃣ History Tab

- **What**: Safety alert records
- **Features**: Timeline view, Weather details, Clear history
- **Action**: Review past safety events

### 4️⃣ Settings Tab

- **What**: Weather parameter simulation
- **Features**: 5 interactive sliders
- **Action**: Test safety system with different conditions

---

## 🆘 Emergency SOS Usage

### Triggering SOS

1. Navigate to SOS Screen
2. **Long-press** the red SOS button
3. Countdown starts (10 seconds)
4. **Release** to cancel, or **hold** to auto-call
5. First emergency contact is called automatically

### Quick Contacts

- 3 quick-access buttons shown
- Tap to call directly
- Pre-loaded: Police, Ambulance, Fire

---

## ⚙️ Configuration

### Default Emergency Contacts

```
1. 🚔 Police - 100
2. 🚑 Ambulance - 102
3. 🚒 Fire Department - 101
```

### Risk Thresholds (Customizable)

```
RAINFALL:
- Safe: < 10mm
- Caution: 10-50mm
- Danger: > 50mm

WIND SPEED:
- Safe: < 20 km/h
- Caution: 20-40 km/h
- Danger: > 40 km/h

VISIBILITY:
- Safe: > 500m
- Caution: 200-500m
- Danger: < 200m

TEMPERATURE:
- Danger: < 0°C or > 40°C
- Caution: 0-5°C or 35-40°C
- Safe: 5-35°C

HUMIDITY:
- Safe: < 90%
- Caution: 90-95%
- Danger: > 95%
```

---

## 🔌 API Integration

### Connect Real Weather Data

```dart
// In your weather service
Future<void> syncSafetyStatus() async {
  final weather = await getWeatherData();

  context.read<SafetyProvider>().checkCurrentSafety(
    rainMm: weather.precipitation,
    windSpeed: weather.windSpeed,
    visibility: weather.visibility,
    temperature: weather.temperature,
    humidity: weather.humidity,
  );
}
```

### Auto-Update on App Start

```dart
// In main.dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  context.read<SafetyProvider>().initializeSafetyMode();
});
```

---

## 💡 Common Tasks

### Check Safety Status

```dart
final safetyProvider = context.read<SafetyProvider>();

if (safetyProvider.currentStatus?.level == HazardLevel.danger) {
  // Show warning
}
```

### Get Recommendations

```dart
import 'package:terra_scope_apk/Services/saftey_service.dart';

final recommendations = SafetyService.getRecommendations(
  safetyProvider.currentStatus!.level
);
```

### Show Safety Alert

```dart
import 'package:terra_scope_apk/utils/safety_notification_manager.dart';

SafetyNotificationManager.showWarning(
  context,
  'Dangerous weather conditions detected'
);
```

### Add Emergency Contact

```dart
final newContact = EmergencyContact(
  id: 'custom_1',
  name: 'Mom',
  phoneNumber: '9876543210',
  email: 'mom@email.com',
  type: EmergencyContactType.family,
);

context.read<SafetyProvider>().addEmergencyContact(newContact);
```

---

## 🎯 Use Cases

### For Farmers

- Monitor weather for safe farming hours
- Get alerts for dangerous conditions
- Quick emergency access if needed

### For Travelers

- Check route safety conditions
- Get real-time weather alerts
- Emergency contact quick access

### For Daily Users

- Be aware of unsafe conditions
- Have quick access to emergency services
- Track weather patterns

---

## ⚡ Performance Tips

1. **Enable Safety Mode Only When Needed**

   - Reduces unnecessary updates

2. **Limit History Size**

   - Automatically keeps last 50 records
   - Older records auto-deleted

3. **Batch API Calls**
   - Update all parameters at once
   - Avoid multiple updates in succession

---

## 🆘 Troubleshooting

### SOS Button Not Working

- Check phone call permissions
- Verify contact has valid number
- Test with a test number first

### Status Not Updating

- Ensure Safety Mode is enabled
- Check SafetyProvider initialization
- Verify currentStatus is not null

### History Not Recording

- Enable Safety Mode first
- Check if currentStatus is null
- Verify SafetyProvider is initialized

### Contacts Not Showing

- Ensure contacts are added to provider
- Check list is not empty
- Verify contact model structure

---

## 📚 Learn More

- See **SAFETY_MODE_DOCUMENTATION.md** for detailed reference
- See **SAFETY_MODE_COMPLETE_GUIDE.md** for comprehensive guide
- See **IMPLEMENTATION_SUMMARY.md** for technical details

---

## 🎓 Code Examples

### Example 1: Complete Safety Check

```dart
class WeatherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SafetyProvider>(
      builder: (context, safetyProvider, _) {
        return SafetyModeScreen();
      },
    );
  }
}
```

### Example 2: Custom Safety Alert

```dart
if (safetyProvider.currentStatus!.level == HazardLevel.danger) {
  SafetyNotificationManager.showEmergencyAlert(
    context,
    title: 'Dangerous Conditions',
    message: safetyProvider.currentStatus!.message,
    warnings: safetyProvider.currentStatus!.warnings,
  );
}
```

### Example 3: Real-time Updates

```dart
@override
void initState() {
  super.initState();
  // Listen to safety changes
  final provider = context.read<SafetyProvider>();
  provider.addListener(() {
    // Rebuild when safety changes
  });
}
```

---

## ✅ Pre-Launch Checklist

- [ ] SafetyProvider initialized in main.dart
- [ ] Safety screens accessible from UI
- [ ] Emergency contacts configured
- [ ] SOS button tested
- [ ] Weather parameters tested
- [ ] History tracking verified
- [ ] Dark mode tested
- [ ] Notifications tested
- [ ] All dependencies added
- [ ] No console errors

---

## 🎉 You're All Set!

Your Safety Mode is ready to use. Start by:

1. Opening SafetyModeScreen
2. Toggling Safety Mode ON
3. Adjusting parameters in Settings
4. Testing SOS functionality
5. Adding your custom contacts

**Happy coding! 🚀**

---

**Quick Links:**

- 📁 [File Locations](#file-structure)
- 🔗 [Integration Guide](#api-integration)
- 📖 [Full Documentation](SAFETY_MODE_COMPLETE_GUIDE.md)

**Last Updated**: December 26, 2025  
**Version**: 1.0.0
