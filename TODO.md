# Nearby Services Implementation Plan

## Status: ✅ In Progress

### Steps:

- [x] 1. Created this TODO.md
- [ ] 2. Add iOS location permissions (Info.plist)
- [✅] 3. Optimize lib/Services/nearby_services.dart (406 fix)
- [✅] 4. Update lib/Screens/care/nearby_services.dart (cache preload)
- [✅] 5. Add navigation button to lib/Screens/traveler/traveler_dashboard.dart
- [✅] 6. Complete lib/Screens/traveler/traveler_nearby_services_screen.dart (auto-location + cache + UI)
- [✅] 7. Initialize cache in lib/Screens/splash_screen.dart
- [ ] 8. Test: flutter run → Care/Traveler → Nearby Services
- [ ] 9. Clean up TODOs + attempt_completion

**Notes:**

- Using OSM Overpass (no API key needed, user confirmed)
- Test in urban area (Bangalore) first
- Priority: police/hospital/clinic as requested
