import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../Services/weather_services.dart';

class RadarScreen extends StatefulWidget {
  final double lat;
  final double lon;

  const RadarScreen({super.key, required this.lat, required this.lon});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  final WeatherService _weatherService = WeatherService();
  late MapController _mapController;
  bool _isLoading = true;
  Map<String, dynamic>? _radarData;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _fetchRadarData();
  }

  Future<void> _fetchRadarData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _weatherService.getRadarData(widget.lat, widget.lon);
      setState(() => _radarData = data);
      debugPrint("✅ Radar data fetched successfully: $_radarData");
    } catch (e) {
      debugPrint("❌ Error fetching radar data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Radar & Weather Maps")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(widget.lat, widget.lon),
                zoom: 6,
                interactiveFlags: InteractiveFlag.all,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                // ✅ RainViewer radar overlay (transparent background)
                TileLayer(
                  urlTemplate: "https://tilecache.rainviewer.com/v2/radar/nowcast/{z}/{x}/{y}/2/1_1.png",
                  backgroundColor: Colors.transparent,
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchRadarData,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
