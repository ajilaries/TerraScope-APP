import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:terra_scope_apk/Services/notification_service.dart';
import 'package:terra_scope_apk/Services/device_service.dart';

class LocationService {
  get deviceToken => null;

  set deviceToken(String deviceToken) {}

  /// 👉 Fast + accurate location fetch
  Future<Position> getCurrentPositionFast() async {
    // 1️⃣ Check service
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception("Location services are disabled.");
    }

    // 2️⃣ Permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied.");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          "Location permissions are permanently denied. Enable them in settings.");
    }

    // 3️⃣ ⚡ First try last known (instant)
    Position? lastPos = await Geolocator.getLastKnownPosition();

    // 4️⃣ Start fetching the accurate one in background
    Future<Position> accuratePos = Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      timeLimit: const Duration(seconds: 10),
    );

    // 5️⃣ Return the fast one first, accurate one later
    return lastPos ?? await accuratePos;
  }

  /// 👉 Convert lat/lon → city + country
  Future<Map<String, String>> getLocationName(double lat, double lon) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);

    String city =
        placemarks.isNotEmpty ? placemarks[0].locality ?? "Unknown" : "Unknown";
    String country =
        placemarks.isNotEmpty ? placemarks[0].country ?? "Unknown" : "Unknown";

    return {"city": city, "country": country};
  }

  /// 👉 Friendly wrapper for HomeScreen2
  Future<Map<String, dynamic>> getCurrentLocation() async {
    Position pos = await getCurrentPositionFast();

    final place = await getLocationName(pos.latitude, pos.longitude);

    return {
      "latitude": pos.latitude,
      "longitude": pos.longitude,
      "city": place["city"],
      "country": place["country"],
    };
  }
Future<Map<String, String>> getLocationNameFromCoordinates(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);

      String city = placemarks.isNotEmpty ? placemarks[0].locality ?? "Unknown" : "Unknown";
      String country = placemarks.isNotEmpty ? placemarks[0].country ?? "Unknown" : "Unknown";

      return {
        "city": city,
        "country": country,
      };
    } catch (e) {
      print("Error getting location name: $e");
      return {"city": "Unknown", "country": "Unknown"};
    }
  }
  /// 👉 Update backend
  Future<void> updateDeviceLocationToBackend() async {
    try {
      final loc = await getCurrentLocation();

      double lat = loc["latitude"];
      double lon = loc["longitude"];

      String? token = await NotificationService.getDeviceToken();
      token ??= DeviceService.getDeviceToken();

      await DeviceService.registerDevice(lat: lat, lon: lon);

      print("✅ Device location updated to backend (token: $token)");
    } catch (e) {
      print("❌ Failed to update device location: $e");
    }
  }
}
