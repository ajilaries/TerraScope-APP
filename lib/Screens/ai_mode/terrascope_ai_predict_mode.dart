/*
Terrascope - AI Predict Mode
File: terrascope_ai_predict_mode.dart

Contents:
1) Top: Backend architecture & API design (detailed comments)
2) Flutter UI implementation (single-file example) for AI Predict Mode with dummy data

USAGE:
- Drop this file into your Flutter project's lib/ folder and import it from main.dart.
- The UI uses only built-in Flutter widgets and minimal custom painters so it runs without extra packages.

--------------------------------------------------------------------------------
BACKEND ARCHITECTURE & FLOW (summary)
--------------------------------------------------------------------------------
Purpose: Provide smart anomaly & predictive insights from historical + real-time weather data
Components:
 1. Data Ingestion (Cloud function / cron job)
    - Fetch real-time + historical weather (e.g., OpenWeatherMap, Meteomatics, NOAA APIs)
    - Store raw readings in a time-series DB (InfluxDB / TimescaleDB) or MongoDB with time indexes
    - Store derived features in a feature store (Redis / Firestore / S3 parquet)

 2. Preprocessing Pipeline
    - Resample to regular intervals (e.g., 10-min)
    - Compute rolling stats: rolling mean/std of humidity, pressure, temp, wind
    - Extract features: pressure drop rate, humidity ramp, wind spike, radar reflectivity summary
    - Label historic anomalies from event logs (heavy rain, flood, storm)

 3. Anomaly Detection & Forecasting Engine
    Option A (Rules + Statistical):
      - Apply statistical thresholds (pressure drop > X in Y mins, humidity rise > Z)
      - Use seasonal decomposition to detect deviations from expected patterns
    Option B (ML):
      - Train a sequence model (LSTM / Transformer) or gradient-boosted model on feature windows
      - Output probabilities for anomaly classes (heavy_rain, storm, heatwave, wind_gust)
    - Ensemble: blend rules + ML for better reliability

 4. Inference Service (REST API)
    - Endpoint: POST /v1/predict
      Body: { "lat":..., "lon":..., "timestamp":..., "recent_readings": [...] }
      Response: {
         "prediction": "heavy_rain",
         "probability": 0.78,
         "timeline": [ {"t": "2025-12-04T14:00Z", "rain_prob":0.8, "temp":25.6}, ... ],
         "explain": {"pressure_drop":22, "humidity_increase":35, "historical_match_score":0.69}
      }

 5. Alert Manager
    - Persist prediction event into DB with TTL & verification status
    - Create alerts for users subscribed to location / polygon
    - Push notifications via FCM (include deep link to AI Predict Mode screen)

 6. Admin Verification (optional)
    - Provide admin UI to review/confirm auto-detected anomalies before wide alerts

Security, scaling & ops:
 - Secure API with API keys / OAuth
 - Rate limit inference, cache repeated requests
 - Use autoscaling inference (Cloud Run / AWS Fargate)
 - Monitor model drift & retrain with new labeled events

Data formats & example
Request:
{
  "lat": 12.97,
  "lon": 77.59,
  "now": "2025-12-04T08:00:00Z",
  "recent": [ {"t":"2025-12-04T07:50:00Z","temp":25.8,"hum":82,"press":1008,"wind":6.2}, ... ]
}
Response:
{
  "prediction":"heavy_rain",
  "probability":0.78,
  "timeline":[ {"t":"2025-12-04T09:00Z","rain_prob":0.65}, ... ],
  "explain":{"pressure_drop":18,"hum_rise":30,"hist_match":0.7}
}

--------------------------------------------------------------------------------
Flutter UI - AI Predict Mode
--------------------------------------------------------------------------------
- Single-screen implementation with:
  * Top hero panel
  * Main prediction card
  * Circular probability meters
  * Horizontal timeline chips
  * "Why this alert" explainer
  * Action suggestions
  * Refresh & auto-update toggle

- Replace dummyData / mocked fetch with real API calls (http package) and map response -> UI models.

*/

import 'dart:async';
import 'package:flutter/material.dart';

class AIPredictModeScreen extends StatefulWidget {
  const AIPredictModeScreen({Key? key}) : super(key: key);

  @override
  State<AIPredictModeScreen> createState() => _AIPredictModeScreenState();
}

class _AIPredictModeScreenState extends State<AIPredictModeScreen> {
  // Dummy state to simulate API
  bool autoUpdate = true;
  DateTime lastUpdated = DateTime.now();
  Map<String, dynamic> prediction = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadDummyPrediction();
    if (autoUpdate) _startAutoRefresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      _loadDummyPrediction();
    });
  }

  void _stopAutoRefresh() {
    _timer?.cancel();
    _timer = null;
  }

  void _toggleAutoUpdate(bool v) {
    setState(() {
      autoUpdate = v;
      if (autoUpdate) _startAutoRefresh(); else _stopAutoRefresh();
    });
  }

  void _loadDummyPrediction() {
    // In real app: call backend /v1/predict and set state from response
    final now = DateTime.now();
    setState(() {
      lastUpdated = now;
      prediction = {
        'title': 'Heavy Rainfall Likely',
        'severity': 'high', // low/medium/high
        'message': 'AI predicts high rainfall activity in next 2–4 hours due to rapid humidity rise.',
        'probabilities': {
          'rain': 0.82,
          'storm': 0.45,
          'temp_anomaly': 0.12,
          'wind_anomaly': 0.27,
        },
        'timeline': List.generate(6, (i) {
          final t = now.add(Duration(hours: i));
          return {
            't': t.toIso8601String(),
            'rain_prob': (0.2 + i * 0.12).clamp(0.0, 1.0),
            'temp': 26 + i,
            'wind': 5 + i * 0.6,
          };
        }),
        'explain': {
          'pressure_drop': 22,
          'humidity_increase': 37,
          'historical_match_score': 0.69
        },
        'actions': [
          'Carry an umbrella',
          'Avoid travel between 2–4 PM',
          'Secure outdoor items',
        ]
      };
    });
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade700, Colors.indigo.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Animated AI icon (static for this example)
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.12),
            ),
            child: Center(
              child: Icon(Icons.cloud, size: 36, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI WEATHER INSIGHT', style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                Text(prediction['title'] ?? 'Analysing patterns...', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(prediction['message'] ?? 'Gathering data and running models…', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Updated', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
              const SizedBox(height: 4),
              Text('${lastUpdated.hour}:${lastUpdated.minute.toString().padLeft(2,'0')}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPredictionCard() {
    final severity = prediction['severity'] ?? 'low';
    Color bg = Colors.green[50]!;
    if (severity == 'medium') bg = Colors.yellow[50]!;
    if (severity == 'high') bg = Colors.red[50]!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(prediction['title'] ?? 'No active predictions', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text(prediction['message'] ?? '', style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildGauge('Rain', (prediction['probabilities']?['rain'] ?? 0.0)),
              const SizedBox(width: 8),
              _buildGauge('Storm', (prediction['probabilities']?['storm'] ?? 0.0)),
              const SizedBox(width: 8),
              _buildGauge('Wind', (prediction['probabilities']?['wind_anomaly'] ?? 0.0)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildGauge(String label, double value) {
    final percent = (value * 100).round();
    Color col = Colors.green;
    if (value > 0.6) col = Colors.red;
    else if (value > 0.3) col = Colors.orange;

    return Expanded(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  value: value.clamp(0.0, 1.0),
                  strokeWidth: 6,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(col),
                ),
              ),
              Text('$percent%', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12))
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final List timeline = prediction['timeline'] ?? [];
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: timeline.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = timeline[index];
          final t = DateTime.parse(item['t']).toLocal();
          final hourLabel = '${t.hour}:00';
          final rain = (item['rain_prob'] as double);
          return Container(
            width: 110,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(hourLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Icon(Icons.umbrella, size: 22),
                const SizedBox(height: 6),
                Text('${(rain * 100).round()}% rain')
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExplainCard() {
    final explain = prediction['explain'] ?? {};
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Why this alert?', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Pressure drop: ${explain['pressure_drop'] ?? '-'} hPa'),
          Text('Humidity increase: ${explain['humidity_increase'] ?? '-'} %'),
          Text('Historical pattern match: ${(explain['historical_match_score'] ?? 0.0).toString()}'),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final List actions = prediction['actions'] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Suggestions', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...actions.map((a) => Row(
          children: [
            const Icon(Icons.check_circle_outline, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(a)),
          ],
        ))
      ],
    );
  }

  Future<void> _manualRefresh() async {
    // call backend here and set state from response
    _loadDummyPrediction();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI prediction refreshed')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Predict Mode'),
        actions: [
          IconButton(onPressed: _manualRefresh, icon: const Icon(Icons.refresh)),
          Switch(value: autoUpdate, onChanged: _toggleAutoUpdate),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHero(),
              const SizedBox(height: 12),
              _buildPredictionCard(),
              const SizedBox(height: 12),
              _buildTimeline(),
              const SizedBox(height: 12),
              _buildExplainCard(),
              const SizedBox(height: 12),
              _buildActions(),
              const SizedBox(height: 12),
              Expanded(child: Container()),
              // footer quick action
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // deep link: navigate to Map / Radar
                      },
                      icon: const Icon(Icons.map),
                      label: const Text('Open Radar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      // share or save alert
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

/*
NEXT STEPS / CONNECTING TO BACKEND
- Replace _loadDummyPrediction() with an HTTP call to your inference endpoint.
  Example:
    final resp = await http.post(Uri.parse('$BASE/api/v1/predict'), body: jsonEncode(payload));
    final body = jsonDecode(resp.body);
    setState((){ prediction = body; lastUpdated = DateTime.now(); });

- Use websockets or server-sent events if you want streaming updates.
- Save user-subscriptions for locations and push FCM messages from the backend when high-confidence predictions occur.

UI IMPROVEMENTS (optional):
- Add animated Lottie / Flare for the AI hero element.
- Replace CircularProgressIndicator with a prettier custom painter or package for fancier gauges.
- Add map preview thumbnails for affected areas.
- Add a confidence slider and allow user feedback (helpful/not helpful) to improve model.

*/
