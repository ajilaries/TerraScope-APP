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
      // First check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return null;
      }

      final hasPermission = await requestPermission();
      if (!hasPermission) {
        print('Location permission denied');
        return null;
      }

      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        timeLimit: const Duration(seconds: 15), // Reduced timeout
      );

      // Try to get position with best accuracy first
      try {
        print('Attempting to get location with best accuracy...');
        final position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings,
        );
        print('Location obtained successfully: ${position.latitude}, ${position.longitude}');
        return position;
      } catch (e) {
        print('Best accuracy failed, trying fallback methods...');

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
          final position = await Geolocator.getCurrentPosition(
            locationSettings: androidSettings,
          );
          print('Location obtained with Android settings: ${position.latitude}, ${position.longitude}');
          return position;
        } catch (androidError) {
          print('Android settings failed: $androidError');

          try {
            // Try Apple settings
            AppleSettings appleSettings = AppleSettings(
              accuracy: LocationAccuracy.best,
              activityType: ActivityType.fitness,
              distanceFilter: 0,
              pauseLocationUpdatesAutomatically: false,
              showBackgroundLocationIndicator: true,
            );
            final position = await Geolocator.getCurrentPosition(
              locationSettings: appleSettings,
            );
            print('Location obtained with Apple settings: ${position.latitude}, ${position.longitude}');
            return position;
          } catch (appleError) {
            print('Apple settings failed: $appleError');

            // Final fallback with updated settings
            LocationSettings fallbackSettings = LocationSettings(
              accuracy: LocationAccuracy.medium, // Lower accuracy for better success rate
              timeLimit: const Duration(seconds: 10),
            );
            final position = await Geolocator.getCurrentPosition(
              locationSettings: fallbackSettings,
            );
            print('Location obtained with fallback settings: ${position.latitude}, ${position.longitude}');
            return position;
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
