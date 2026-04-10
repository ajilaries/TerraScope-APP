# Safety Mode Architecture Overview

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Main Application                         │
│                      (main.dart)                             │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┴───────────────┐
        │                              │
┌───────▼──────────┐         ┌────────▼─────────┐
│  ModeProvider    │         │ SafetyProvider   │
│  (Theme Mode)    │         │  (Safety State)  │
└──────────────────┘         └────────┬─────────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    │                 │                 │
            ┌───────▼────────┐  ┌──────▼─────┐  ┌────▼─────────┐
            │ Safety Service │  │ Location   │  │ Notification │
            │ (Algorithms)   │  │ Service    │  │ Manager      │
            └────────────────┘  └────────────┘  └──────────────┘
```

## 📊 Data Flow

```
User Action
    │
    ├─▶ Toggle Safety Mode
    │   └─▶ SafetyProvider.toggleSafetyMode()
    │       └─▶ checkCurrentSafety()
    │           └─▶ SafetyService.checkSafety()
    │               └─▶ Calculate Risk Score
    │                   └─▶ SafetyStatus Updated
    │                       └─▶ UI Re-renders
    │
    ├─▶ Adjust Weather Parameter
    │   └─▶ Slider onChange
    │       └─▶ SafetyProvider.checkCurrentSafety()
    │           └─▶ Risk Score Recalculated
    │               └─▶ SafetyStatus Updated
    │                   └─▶ UI Re-renders
    │
    ├─▶ Tap Emergency Contact
    │   └─▶ EmergencyContactCard.makeCall()
    │       └─▶ URL Launch (tel:)
    │           └─▶ Phone Dialer Opens
    │
    └─▶ Press SOS Button
        └─▶ 10 Second Countdown
            └─▶ Auto-Call First Contact
                └─▶ SafetyAlert Recorded
                    └─▶ History Updated
```

## 🎯 Feature Map

```
┌────────────────────────────────────────────────────────────┐
│                   SAFETY MODE SYSTEM                        │
├────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │            MONITORING & DETECTION                     │  │
│  ├──────────────────────────────────────────────────────┤  │
│  │ • Real-time Weather Monitoring                        │  │
│  │ • Multi-parameter Analysis (5 parameters)             │  │
│  │ • Risk Scoring (0-100)                                │  │
│  │ • Hazard Level Classification                         │  │
│  │ • Automatic Alert Generation                          │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │            EMERGENCY MANAGEMENT                       │  │
│  ├──────────────────────────────────────────────────────┤  │
│  │ • Emergency Contacts (Pre-loaded 3, User Customizable) │  │
│  │ • SOS Button (10-sec Countdown)                       │  │
│  │ • Auto-Call First Contact                             │  │
│  │ • Quick Contact Access                                │  │
│  │ • SMS/Email Support (Framework Ready)                 │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         HISTORY & ANALYTICS                          │  │
│  ├──────────────────────────────────────────────────────┤  │
│  │ • Automatic Alert Logging (50 record limit)           │  │
│  │ • Timestamp Tracking                                  │  │
│  │ • Weather Condition Recording                         │  │
│  │ • History Viewing & Export                            │  │
│  │ • Clear History Option                                │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │        SMART RECOMMENDATIONS                         │  │
│  ├──────────────────────────────────────────────────────┤  │
│  │ • Context-aware Safety Advice                         │  │
│  │ • Activity-specific Guidance                          │  │
│  │ • Real-time Updates                                   │  │
│  │ • Hazard-level Based Recommendations                  │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
└────────────────────────────────────────────────────────────┘
```

## 🎨 UI Component Hierarchy

```
SafetyModeScreen (Main Screen)
├── AppBar
│   └── TabBar (4 Tabs)
│
├── Tab 1: Status
│   ├── SwitchListTile (Toggle Safety Mode)
│   ├── DetailedSafetyCard
│   │   ├── Header (Status + Risk Score)
│   │   ├── Message Container
│   │   ├── Weather Parameter Grid
│   │   │   ├── _WeatherParamTile (x6)
│   │   │   │   ├── Icon
│   │   │   │   ├── Label
│   │   │   │   └── Value
│   │   │   └── ...
│   │   ├── Warnings List
│   │   └── Timestamp
│   └── Recommendations List
│
├── Tab 2: Contacts
│   ├── Emergency Contacts List
│   │   └── EmergencyContactCard (x N)
│   │       ├── Header (Name + Icon)
│   │       ├── Phone Tile (Clickable)
│   │       ├── Email Tile (If Available)
│   │       └── Notes Tile (If Available)
│   └── Add Contact Button
│
├── Tab 3: History
│   ├── Safety History List
│   │   └── SafetyHistoryCard (x 50 max)
│   │       ├── Header (Status + Time)
│   │       └── Parameter Badges
│   └── Clear History Button
│
└── Tab 4: Settings
    ├── Rainfall Slider
    ├── Wind Speed Slider
    ├── Visibility Slider
    ├── Temperature Slider
    └── Humidity Slider
```

## 📦 File Dependencies

```
main.dart
├── safety_provider.dart
│   ├── saftey_service.dart
│   │   ├── saftey_status.dart
│   │   └── safety_utils.dart
│   └── emergency_contact.dart
│
saftey_mode_screen.dart
├── safety_provider.dart
├── saftey_service.dart
├── detailed_safety_card.dart
│   ├── safety_utils.dart
│   └── saftey_status.dart
├── emergency_contact_card.dart
│   └── emergency_contact.dart
└── safety_history_card.dart
    ├── safety_utils.dart
    ├── saftey_status.dart
    └── safety_provider.dart
```

## 🔄 State Management Flow

```
┌─────────────────────────────────────────────┐
│         SafetyProvider (ChangeNotifier)    │
├─────────────────────────────────────────────┤
│                                             │
│  State Variables:                           │
│  ├── bool _isSafetyModeEnabled              │
│  ├── SafetyStatus? _currentStatus           │
│  ├── List<EmergencyContact> _contacts       │
│  ├── List<SafetyAlert> _safetyHistory       │
│  ├── bool _isLoading                        │
│  └── String? _errorMessage                  │
│                                             │
│  Methods:                                   │
│  ├── initializeSafetyMode()                 │
│  ├── toggleSafetyMode(bool)                 │
│  ├── checkCurrentSafety(...)                │
│  ├── addEmergencyContact(...)               │
│  ├── removeEmergencyContact(...)            │
│  ├── loadEmergencyContacts()                │
│  ├── loadSafetyHistory()                    │
│  ├── clearSafetyHistory()                   │
│  └── getSafetyScore()                       │
│                                             │
└─────────────────────────────────────────────┘
         │
         │ notifyListeners() ──────────┐
         │                              │
         └──────────────────┬───────────┘
                            │
                    ┌───────▼──────────┐
                    │   Consumer       │
                    │  (UI Rebuild)    │
                    └──────────────────┘
```

## 🎯 Risk Scoring Algorithm

```
START: Risk Score = 0

RAINFALL CHECK:
├─ > 50mm? ──▶ +40 points
├─ > 10mm? ──▶ +15 points
└─ Else   ──▶ +0 points

WIND SPEED CHECK:
├─ > 40 km/h? ──▶ +40 points
├─ > 20 km/h? ──▶ +15 points
└─ Else      ──▶ +0 points

VISIBILITY CHECK:
├─ < 200m?  ──▶ +40 points
├─ < 500m?  ──▶ +20 points
└─ Else     ──▶ +0 points

TEMPERATURE CHECK:
├─ >45°C or <-10°C? ──▶ +20 points
├─ >40°C or <0°C?   ──▶ +10 points
└─ Else             ──▶ +0 points

HUMIDITY CHECK:
├─ > 90%? ──▶ +10 points
└─ Else  ──▶ +0 points

TOTAL SCORE CALCULATION:
├─ >= 60? ──▶ DANGER   🔴
├─ >= 30? ──▶ CAUTION  🟠
└─ Else  ──▶ SAFE     🟢

OUTPUT: HazardLevel + Message + Warnings
```

## 📱 Screen Navigation

```
Main App
│
├─ SafetyModeScreen (4 Tabs)
│  ├─ Status Tab
│  │  └─ Detailed View
│  ├─ Contacts Tab
│  │  └─ Contact Details
│  ├─ History Tab
│  │  └─ Alert Details
│  └─ Settings Tab
│     └─ Parameter Adjustment
│
└─ SOSScreen
   ├─ SOS Button
   ├─ Countdown Timer
   └─ Quick Contacts
```

## 💾 Data Models

```
SafetyStatus
├── HazardLevel level
├── String message
├── DateTime time
├── int riskScore
├── List<String> warnings
└── Methods: emoji, colorName

SafetyAlert
├── HazardLevel level
├── String message
├── DateTime timestamp
├── double rainMm
├── double windSpeed
├── int visibility
└── double temperature

EmergencyContact
├── String id
├── String name
├── String phoneNumber
├── String email
├── EmergencyContactType type
├── String? notes
└── String icon (computed)

EmergencyContactType (Enum)
├── police
├── ambulance
├── fire
├── family
├── friend
└── custom
```

## 🚀 Quick Start

1. **Initialize**: SafetyProvider initialized in main.dart ✅
2. **Enable**: Toggle Safety Mode in Status tab
3. **Monitor**: Watch real-time status updates
4. **Contact**: Manage emergency contacts
5. **Emergency**: Use SOS for quick access
6. **History**: Review past safety events
7. **Adjust**: Test with Settings sliders

---

**System Ready: ✅ PRODUCTION READY**
