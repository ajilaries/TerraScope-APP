import 'package:flutter/material.dart';
import 'dart:math';

class FarmerSoilAnalysis extends StatefulWidget {
  const FarmerSoilAnalysis({super.key});

  @override
  State<FarmerSoilAnalysis> createState() => _FarmerSoilAnalysisState();
}

class _FarmerSoilAnalysisState extends State<FarmerSoilAnalysis>
    with SingleTickerProviderStateMixin {
  // demo/mock data (replace with real backend values later)
  final List<double> moistureTrend = [62, 60, 58, 65, 70, 68, 62];
  final double currentMoisture = 62; // %
  final double soilPH = 6.2;
  final int fertilityScore = 74; // 0-100
  final int nVal = 30;
  final int pVal = 55;
  final int kVal = 70;

  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
          ..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _scoreColor(int score) {
    if (score >= 75) return Colors.green.shade700;
    if (score >= 45) return Colors.orange.shade700;
    return Colors.red.shade700;
  }
  Widget _sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
        title: const Text(
          "Soil Analysis",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header + current moisture gauge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Moisture Gauge
                Expanded(
                  flex: 4,
                  child: _moistureGauge(),
                ),

                const SizedBox(width: 12),

                // Quick stats
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _statCard(
                        title: "Soil pH",
                        value: soilPH.toStringAsFixed(1),
                        subtitle: _phInterpretation(soilPH),
                        icon: Icons.scale,
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(height: 12),
                      _statCard(
                        title: "Fertility Score",
                        value: "$fertilityScore",
                        subtitle: fertilityScore >= 70
                            ? "Good fertility"
                            : (fertilityScore >= 45 ? "Moderate" : "Low"),
                        icon: Icons.leaderboard,
                        color: _scoreColor(fertilityScore),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Moisture trend sparkline
            _sectionTitle("Soil Moisture Trend (last 7 days)"),
            const SizedBox(height: 8),
            _sparklineCard(moistureTrend),

            const SizedBox(height: 16),

            // NPK Bars
            _sectionTitle("NPK Levels"),
            const SizedBox(height: 8),
            _npkBars(nVal, pVal, kVal),

            const SizedBox(height: 18),

            // Suggested Crops
            _sectionTitle("Recommended Crops"),
            const SizedBox(height: 8),
            _recommendedCrops(),

            const SizedBox(height: 16),

            // Smart suggestions
            _sectionTitle("Smart Suggestions"),
            const SizedBox(height: 8),
            _suggestionsCard(),

            const SizedBox(height: 18),

            // CTA
            _runTestCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _moistureGauge() {
    final animatedValue =
        Tween<double>(begin: 0, end: currentMoisture / 100).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Soil Moisture",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            width: 140,
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: animatedValue.value,
                      strokeWidth: 14,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        animatedValue.value > 0.7
                            ? Colors.green.shade700
                            : (animatedValue.value > 0.45 ? Colors.orange.shade700 : Colors.red.shade700),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${(animatedValue.value * 100).round()}%",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Moisture",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    )
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _moistureAdvice(currentMoisture),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
          )
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _sparklineCard(List<double> data) {
    return Container(
      padding: const EdgeInsets.all(12),
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Moisture (%)", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: CustomPaint(
                painter: _SparklinePainter(data),
                child: Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _npkBars(int n, int p, int k) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))
      ]),
      child: Column(
        children: [
          _singleBar("Nitrogen (N)", n, Colors.lightGreen),
          const SizedBox(height: 8),
          _singleBar("Phosphorus (P)", p, Colors.amber),
          const SizedBox(height: 8),
          _singleBar("Potassium (K)", k, Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _singleBar(String label, int value, Color color) {
    final percent = (value / 100).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label — $value%"),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 12,
            color: Colors.grey.shade200,
            child: LayoutBuilder(builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    width: constraints.maxWidth * percent,
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _recommendedCrops() {
    // simple rule-based demo logic
    final List<Map<String, dynamic>> crops = [
      {"name": "Paddy", "score": 88},
      {"name": "Coconut", "score": 80},
      {"name": "Pepper", "score": 70},
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))
      ]),
      child: Column(
        children: crops.map((c) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 6),
            leading: CircleAvatar(backgroundColor: Colors.green.shade100, child: Text(c["name"][0])),
            title: Text(c["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Suitability: ${c["score"]}%"),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
              onPressed: () {
                // navigate to crop health or crop detail
                // Navigator.push(...);
              },
              child: const Text("View"),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _suggestionsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• Avoid watering right before forecasted heavy rain."),
          const SizedBox(height: 6),
          const Text("• Add organic compost to improve N-levels."),
          const SizedBox(height: 6),
          Text("• Recommended next soil test: ${_nextTestDays()} days",
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _runTestCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))
      ]),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Want a detailed soil report?", style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Text("Send a sample to our lab or run the in-app sensor test."),
              ],
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.biotech),
            label: const Text("Run Soil Test"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
            onPressed: () {
              // hook to backend or sensor
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Soil test started (demo)")),
              );
            },
          ),
        ],
      ),
    );
  }

  String _phInterpretation(double ph) {
    if (ph < 5.5) return "Acidic — consider liming";
    if (ph <= 7.5) return "Neutral to slightly alkaline";
    return "High alkaline — crop-specific advice needed";
  }

  String _moistureAdvice(double m) {
    if (m < 40) return "Soil is dry — irrigation recommended soon.";
    if (m <= 75) return "Moisture good — optimal for most crops.";
    return "Soil very wet — delay watering.";
  }

  int _nextTestDays() {
    // demo: worse fertility -> sooner test
    if (fertilityScore < 50) return 7;
    if (fertilityScore < 70) return 30;
    return 90;
  }
}

// --------------------------
// Custom Painter for sparkline
// --------------------------
class _SparklinePainter extends CustomPainter {
  final List<double> points;
  _SparklinePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.green.shade700
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintFill = Paint()
      ..color = Colors.green.shade100.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    if (points.isEmpty) return;

    final maxVal = points.reduce(max);
    final minVal = points.reduce(min);

    final double dx = size.width / (points.length - 1);
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < points.length; i++) {
      final x = dx * i;
      final normalized = (points[i] - minVal) / (maxVal - minVal + 0.0001);
      final y = size.height - (normalized * size.height);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // close fill path to bottom right & bottom left
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);

    // draw dots
    final dotPaint = Paint()..color = Colors.green.shade800;
    for (int i = 0; i < points.length; i++) {
      final x = dx * i;
      final normalized = (points[i] - minVal) / (maxVal - minVal + 0.0001);
      final y = size.height - (normalized * size.height);
      canvas.drawCircle(Offset(x, y), 2.6, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
