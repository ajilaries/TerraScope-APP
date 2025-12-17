import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:terra_scope_apk/Services/notification_service.dart';
import 'package:terra_scope_apk/Services/device_service.dart';

class LocationService {
  String? _deviceToken;

  String? get deviceToke => _deviceToken;
  set deviceToken(String? token) {
    _deviceToken = token;
  }

  /// 👉 Fast + accurate location fetch
  Future<Position> getCurrentPositionFast() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception("Location services are disabled.");
    }

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

    Position? lastPos = await Geolocator.getLastKnownPosition();

    Future<Position> accuratePos = Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      timeLimit: const Duration(seconds: 10),
    );

    return lastPos ?? await accuratePos;
  }

  /// 👉 Convert lat/lon → city + state + district + country (MOST IMPORTANT)
  Future<Map<String, String>> getAdministrativeDetails(
      double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);

      final place = placemarks.first;

      return {
        "city": place.locality ?? "Unknown",
        "district": place.subAdministrativeArea ?? "Unknown",
        "state": place.administrativeArea ?? "Unknown",
        "country": place.country ?? "Unknown",
      };
    } catch (e) {
      print("❌ Error getting admin details: $e");
      return {
        "city": "Unknown",
        "district": "Unknown",
        "state": "Unknown",
        "country": "Unknown",
      };
    }
  }

  /// 👉 Friendly wrapper for HomeScreen2
  Future<Map<String, dynamic>> getCurrentLocation() async {
    Position pos = await getCurrentPositionFast();

    final place = await getAdministrativeDetails(pos.latitude, pos.longitude);

    return {
      "latitude": pos.latitude,
      "longitude": pos.longitude,
      "city": place["city"],
      "district": place["district"],
      "state": place["state"],
      "country": place["country"],
    };
  }

  /// 👉 Simple city+country lookup (old method, still used somewhere)
  Future<Map<String, String>> getLocationNameFromCoordinates(
      double lat, double lon) async {
    try {
      return await getAdministrativeDetails(lat, lon);
    } catch (e) {
      print("Error: $e");
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
      token ??= await DeviceService.getDeviceToken();

      await DeviceService.registerDevice(lat: lat, lon: lon);

      print("✅ Device location updated to backend (token: $token)");
    } catch (e) {
      print("❌ Failed to update device location: $e");
    }
  }
}
