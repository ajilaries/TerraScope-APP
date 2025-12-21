import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../Services/weather_services.dart';

class RadarScreen extends StatefulWidget {
  final double lat;
  final double lon;

  const RadarScreen({
    super.key,
    required this.lat,
    required this.lon,
  });

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  final WeatherService _weatherService = WeatherService();
  late final MapController _mapController;

  bool _isLoading = true;
  double _radarOpacity = 0.6;
  String _rainStatus = "No data";

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

      final rain = data['hourly']?[0]?['rain']?['1h'] ?? 0.0;

      setState(() {
        _rainStatus = _getRainStatus(rain);
      });

      _mapController.move(
        LatLng(widget.lat, widget.lon),
        6,
      );
    } catch (e) {
      debugPrint("❌ Radar fetch failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getRainStatus(double rain) {
    if (rain >= 20) return "🚨 Heavy Rainfall";
    if (rain >= 5) return "🌧️ Moderate Rain";
    if (rain > 0) return "🌦️ Light Rain";
    return "☀️ No Rain";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Radar & Weather"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRadarData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: LatLng(widget.lat, widget.lon),
                    zoom: 6,
                    interactiveFlags: InteractiveFlag.all,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                    ),

                    // 🌧️ RainViewer Radar Layer
                    Opacity(
                      opacity: _radarOpacity,
                      child: TileLayer(
                        urlTemplate:
                            "https://tilecache.rainviewer.com/v2/radar/nowcast/{z}/{x}/{y}/2/1_1.png",
                        backgroundColor: Colors.transparent,
                      ),
                    ),

                    // 📍 Location Marker
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(widget.lat, widget.lon),
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // 🧠 Radar Info Panel
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _rainStatus,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Slider(
                            value: _radarOpacity,
                            min: 0.2,
                            max: 1.0,
                            divisions: 8,
                            label: "Opacity ${(_radarOpacity * 100).round()}%",
                            onChanged: (value) {
                              setState(() => _radarOpacity = value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
