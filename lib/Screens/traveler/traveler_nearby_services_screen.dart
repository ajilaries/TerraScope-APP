import 'package:flutter/material.dart';
import '../../Services/nearby_services.dart';
import 'travel_map_preview.dart';
import 'package:latlong2/latlong.dart';

class TravelerNearbyServicesScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const TravelerNearbyServicesScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<TravelerNearbyServicesScreen> createState() => _TravelerNearbyServicesScreenState();
}

class _TravelerNearbyServicesScreenState extends State<TravelerNearbyServicesScreen> {
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;
  String _selectedServiceType = 'hospital';
  final List<String> _serviceTypes = ['hospital', 'pharmacy', 'clinic', 'police'];

  @override
  void initState() {
    super.initState();
    _loadNearbyServices();
  }

  Future<void> _loadNearbyServices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final services = await NearbyServices.searchNearbyServices(
        _selectedServiceType,
        widget.latitude,
        widget.longitude,
        5000, // 5km radius
      );

      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading services: $e")),
        );
      }
    }
  }

  void _onServiceTypeChanged(String? newType) {
    if (newType != null && newType != _selectedServiceType) {
      setState(() {
        _selectedServiceType = newType;
      });
      _loadNearbyServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Services"),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNearbyServices,
          ),
        ],
      ),
      body: Column(
        children: [
          // Service type selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                const Text(
                  "Service Type:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedServiceType,
                    isExpanded: true,
                    items: _serviceTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: _onServiceTypeChanged,
                  ),
                ),
              ],
            ),
          ),

          // Map preview
          Container(
            height: 150,
            padding: const EdgeInsets.all(8),
            child: TravelMapPreview(
              location: LatLng(widget.latitude, widget.longitude),
            ),
          ),

          // Services list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _services.isEmpty
                    ? const Center(
                        child: Text(
                          "No services found nearby",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _services.length,
                        itemBuilder: (context, index) {
                          final service = _services[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getServiceColor(_selectedServiceType),
                                child: Icon(
                                  _getServiceIcon(_selectedServiceType),
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(service['name'] ?? 'Unknown'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(service['address'] ?? 'Address not available'),
                                  Text(
                                    service['distance'] ?? 'Distance unknown',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: service['phone'] != null && service['phone'] != 'Not available'
                                  ? IconButton(
                                      icon: const Icon(Icons.phone, color: Colors.green),
                                      onPressed: () {
                                        // In a real app, this would launch the phone dialer
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Call: ${service['phone']}")),
                                        );
                                      },
                                    )
                                  : null,
                              onTap: () {
                                _showServiceDetails(service);
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showServiceDetails(Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service['name'] ?? 'Service Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (service['address'] != null)
              Text("Address: ${service['address']}"),
            if (service['phone'] != null && service['phone'] != 'Not available')
              Text("Phone: ${service['phone']}"),
            if (service['distance'] != null)
              Text("Distance: ${service['distance']}"),
            if (service['isOpen'] != null)
              Text("Status: ${service['isOpen'] ? 'Open' : 'Closed'}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          if (service['phone'] != null && service['phone'] != 'Not available')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Call: ${service['phone']}")),
                );
              },
              child: const Text("Call"),
            ),
        ],
      ),
    );
  }

  Color _getServiceColor(String type) {
    switch (type) {
      case 'hospital':
        return Colors.red;
      case 'pharmacy':
        return Colors.blue;
      case 'clinic':
        return Colors.green;
      case 'police':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getServiceIcon(String type) {
    switch (type) {
      case 'hospital':
        return Icons.local_hospital;
      case 'pharmacy':
        return Icons.medical_services;
      case 'clinic':
        return Icons.healing;
      case 'police':
        return Icons.local_police;
      default:
        return Icons.place;
    }
  }
}
