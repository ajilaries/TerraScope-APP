# TODO: Fix withValues to withOpacity Errors

## Overview

Replace all instances of `withValues(alpha: value)` with `withOpacity(value)` in Color objects across multiple Dart files to fix compilation errors.

## Steps

- [x] Edit lib/Widgets/saftey_card.dart (1 instance)
- [x] Edit lib/Widgets/safety_history_card.dart (1 instance)
- [ ] Edit lib/Widgets/emergency_contact_card.dart (3 instances)
- [ ] Edit lib/Widgets/detailed_safety_card.dart (6 instances)
- [x] Edit lib/utils/safety_notification_manager.dart (2 instances)
- [x] Edit lib/Screens/traveler/traveler_saftey_card.dart (1 instance)
- [x] Edit lib/Screens/settings_screen.dart (5 instances)
- [ ] Edit lib/Screens/saftey/saftey_mode_screen.dart (4 instances)
- [x] Edit lib/Screens/home_screen2.dart (1 instance)
- [x] Edit lib/Screens/home_screen.dart (1 instance)
- [ ] Edit lib/Screens/anomaly_screen.dart (3 instances)
- [x] Edit lib/Screens/anomalies_screen.dart (1 instance)
- [ ] Run flutter analyze to verify fixes
