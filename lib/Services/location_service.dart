import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Fetches the most accurate and fast location
  Future<Map<String, dynamic>> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable them.');
    }

    // Check and request permission
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

    // Try to get last known position (faster response)
    Position? position = await Geolocator.getLastKnownPosition();

    // If no cached position, get precise GPS location
    position ??= await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    // Convert coordinates to human-readable place name
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    String city = placemarks.isNotEmpty ? placemarks[0].locality ?? "Unknown" : "Unknown";
    String country = placemarks.isNotEmpty ? placemarks[0].country ?? "" : "";

    return {
      "latitude": position.latitude,
      "longitude": position.longitude,
      "city": city,
      "country": country,
    };
  }
}
