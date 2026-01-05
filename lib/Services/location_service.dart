import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) return null;

      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        timeLimit: const Duration(seconds: 30), // Timeout after 30 seconds
      );

      // Try to get position with best accuracy first
      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: locationSettings,
        );
      } catch (e) {
        // Fallback to platform-specific settings based on platform
        try {
          // Try Android settings first (works on both platforms but optimized for Android)
          AndroidSettings androidSettings = AndroidSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 0, // Get all location updates
            forceLocationManager: true, // Use GPS over network
            intervalDuration: const Duration(seconds: 1),
            foregroundNotificationConfig: const ForegroundNotificationConfig(
              notificationText:
                  "TerraScope is getting your location for safety monitoring",
              notificationTitle: "Location Access",
              enableWakeLock: true,
            ),
          );
          return await Geolocator.getCurrentPosition(
            locationSettings: androidSettings,
          );
        } catch (androidError) {
          try {
            // Try Apple settings
            AppleSettings appleSettings = AppleSettings(
              accuracy: LocationAccuracy.best,
              activityType: ActivityType.fitness,
              distanceFilter: 0,
              pauseLocationUpdatesAutomatically: false,
              showBackgroundLocationIndicator: true,
            );
            return await Geolocator.getCurrentPosition(
              locationSettings: appleSettings,
            );
          } catch (appleError) {
            // Final fallback with updated settings
            LocationSettings fallbackSettings = LocationSettings(
              accuracy: LocationAccuracy.high,
            );
            return await Geolocator.getCurrentPosition(
              locationSettings: fallbackSettings,
            );
          }
        }
      }
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  static Future<String?> getAddressFromCoordinates(
      double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.locality}, ${place.country}';
      }
      return null;
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }

  static Future<List<Location>?> getCoordinatesFromAddress(
      String address) async {
    try {
      return await locationFromAddress(address);
    } catch (e) {
      print('Error getting coordinates: $e');
      return null;
    }
  }

  static Stream<Position> getPositionStream() {
    // Enhanced position stream for safety monitoring
    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 50, // Update every 50 meters
      timeLimit: const Duration(seconds: 30),
    );

    return Geolocator.getPositionStream(
      locationSettings: locationSettings,
    );
  }

  static Future<Position?> getCurrentLocation() async {
    return await getCurrentPosition();
  }

  static Future<String?> getLocationNameFromCoordinates(
      double lat, double lon) async {
    return await getAddressFromCoordinates(lat, lon);
  }

  static Future<Position?> getCurrentPositionFast() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) return null;

      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.medium,
      );
      return await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
    } catch (e) {
      print('Error getting fast location: $e');
      return null;
    }
  }

  static Future<Map<String, String>?> getAdministrativeDetails(
      double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return {
          'country': place.country ?? '',
          'state': place.administrativeArea ?? '',
          'city': place.locality ?? '',
          'district': place.subAdministrativeArea ?? '',
        };
      }
      return null;
    } catch (e) {
      print('Error getting administrative details: $e');
      return null;
    }
  }
}
