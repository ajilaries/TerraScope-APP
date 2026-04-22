import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Services/location_service.dart';
import '../../Services/nearby_services.dart';
import '../../Services/nearby_cache_service.dart';

class NearbyServicesScreen extends StatefulWidget {
  const NearbyServicesScreen({super.key});

  @override
  State<NearbyServicesScreen> createState() => _NearbyServicesScreenState();
}

class _NearbyServicesScreenState extends State<NearbyServicesScreen> {
  bool _isLoading = false;
  String _currentLocation = 'Getting location...';
  List<Map<String, dynamic>> _services = [];

  final List<Map<String, dynamic>> _serviceTypes = [
    {
      'name': 'Hospitals',
      'icon': Icons.local_hospital,
      'color': Colors.red,
      'query': 'hospital',
    },
    {
      'name': 'Pharmacies',
      'icon': Icons.local_pharmacy,
      'color': Colors.green,
      'query': 'pharmacy',
    },
    {
      'name': 'Clinics',
      'icon': Icons.medical_services,
      'color': Colors.blue,
      'query': 'clinic',
    },
    {
      'name': 'Emergency Rooms',
      'icon': Icons.emergency,
      'color': Colors.red.shade800,
      'query': 'emergency room',
    },
    {
      'name': 'Medical Centers',
      'icon': Icons.health_and_safety,
      'color': Colors.purple,
      'query': 'medical center',
    },
    {
      'name': 'Urgent Care',
      'icon': Icons.warning,
      'color': Colors.orange,
      'query': 'urgent care',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeCache();
    _getCurrentLocation();
  }

  Future<void> _initializeCache() async {
    await NearbyCacheService.initializeCache();
    final position = await LocationService.getCurrentPosition();
    if (position != null) {
      await NearbyCacheService.preloadNearbyServices(
          position.latitude, position.longitude);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        setState(() {
          _currentLocation =
              '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        });
      } else {
        setState(() {
          _currentLocation = 'Location not available';
        });
      }
    } catch (e) {
      setState(() {
        _currentLocation = 'Error getting location';
      });
      print('Error getting location: $e');
    }
  }

  Future<void> _searchNearbyServices(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current location
      final position = await LocationService.getCurrentPosition();
      if (position == null) {
        throw Exception('Unable to get current location');
      }

      // Try cache first, then API
      List<Map<String, dynamic>> services =
          NearbyCacheService.getCachedServices(query);
      if (services.isEmpty) {
        services = await NearbyServices.searchNearbyServices(
          query,
          position.latitude,
          position.longitude,
          1500,
        );
        // Preload cache
        NearbyCacheService.preloadNearbyServices(
                position.latitude, position.longitude)
            .catchError((e) => print('Cache preload failed: $e'));
      }

      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _makeCall(String phoneNumber) async {
    if (phoneNumber == 'N/A' || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
      return;
    }

    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(launchUri);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not make call: $e')),
      );
    }
  }

  Future<void> _openInMaps(Map<String, dynamic> service) async {
    final latitude = service['latitude'];
    final longitude = service['longitude'];
    final address = service['address'];

    String url;
    if (latitude != null && longitude != null) {
      url =
          'https://www.openstreetmap.org/?mlat=$latitude&mlon=$longitude#map=17/$latitude/$longitude';
    } else {
      final query = Uri.encodeComponent(address);
      url = 'https://www.openstreetmap.org/search?query=$query';
    }

    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open maps: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Services'),
        backgroundColor: Colors.deepPurple.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                _searchNearbyServices(_serviceTypes.first['query'] as String),
          ),
        ],
      ),
      body: Column(
        children: [
          // Location Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.deepPurple.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Current Location: $_currentLocation',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _getCurrentLocation,
                  tooltip: 'Refresh Location',
                ),
              ],
            ),
          ),

          // Service Type Buttons
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _serviceTypes
                  .map((service) => Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        child: _serviceTypeButton(service),
                      ))
                  .toList(),
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _services.isEmpty
                    ? _buildEmptyState()
                    : _buildServicesList(),
          ),
        ],
      ),
    );
  }

  Widget _serviceTypeButton(Map<String, dynamic> service) {
    return GestureDetector(
      onTap: () => _searchNearbyServices(service['query'] as String),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              service['icon'] as IconData,
              size: 32,
              color: service['color'] as Color,
            ),
            const SizedBox(height: 8),
            Text(
              service['name'] as String,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No services found within 1.5km',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () =>
                _searchNearbyServices(_serviceTypes.first['query'] as String),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry Search'),
          ),
          const SizedBox(height: 8),
          Text(
            '$_currentLocation',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList() {
    return RefreshIndicator(
      onRefresh: () =>
          _searchNearbyServices(_serviceTypes.first['query'] as String),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _services.length,
        itemBuilder: (context, index) {
          final service = _services[index];
          final isOpen = service['isOpen'] as bool? ?? false;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          service['name'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isOpen ? 'Open' : 'Closed',
                          style: TextStyle(
                            color: isOpen
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          service['address'] as String,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        service['phone'] as String,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${service['rating']}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Text(
                        service['distance'] as String,
                        style: TextStyle(
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _makeCall(service['phone'] as String),
                          icon: const Icon(Icons.call, size: 16),
                          label: const Text('Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openInMaps(service),
                          icon: const Icon(Icons.directions, size: 16),
                          label: const Text('Directions'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
