import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:terra_scope_apk/Services/notification_service.dart';
import 'package:terra_scope_apk/Services/device_service.dart';

class LocationService {
  String? deviceToken; // ✅ Store device token here for reuse

  /// Fetches the most accurate and fast location
  Future<Map<String, dynamic>> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable them.');
    }

    // Check and request permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Please enable them from settings.',
      );
    }

    // Get last known position (fast) or current position (accurate)
    Position? position = await Geolocator.getLastKnownPosition();
    position ??= await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    // Convert coordinates to human-readable place
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    String city = placemarks.isNotEmpty
        ? placemarks[0].locality ?? "Unknown"
        : "Unknown";
    String country = placemarks.isNotEmpty ? placemarks[0].country ?? "" : "";

    return {
      "latitude": position.latitude,
      "longitude": position.longitude,
      "city": city,
      "country": country,
    };
  }

  /// Updates device location to backend (includes token handling)
  Future<void> updateDeviceLocationToBackend() async {
    try {
      // 1️⃣ Get current location
      final locData = await getCurrentLocation();
      double lat = locData["latitude"];
      double lon = locData["longitude"];

      // 2️⃣ Get FCM token
      String? token = await NotificationService.getDeviceToken();

      // 3️⃣ Fallback to DeviceService token if FCM token unavailable
      token ??= DeviceService.getDeviceToken();

      // 4️⃣ Register device to backend
      await DeviceService.registerDevice(lat: lat, lon: lon);
      print("✅ Device location updated to backend (token: $token)");
    } catch (e) {
      print("❌ Failed to update device location: $e");
    }
  }
}
