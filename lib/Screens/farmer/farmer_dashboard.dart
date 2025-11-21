// Terrascope - Farmer Mode Demo
// Single-file Flutter example showing:
// - Mode selection (Farmer)
// - Theme (Light/Dark) applied globally
// - FarmerDashboard with basic and addon features loaded for farmer mode
// Add `provider: ^6.0.0` to your pubspec.yaml

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const TerrascopeApp(),
    ),
  );
}

class AppState extends ChangeNotifier {
  // Modes: 'standard', 'farmer', 'travel', etc.
  String _mode = 'standard';
  bool _isDark = false;
  bool get isDark => _isDark;
  String get mode => _mode;

  void setMode(String m) {
    _mode = m;
    notifyListeners();
  }

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

class TerrascopeApp extends StatelessWidget {
  const TerrascopeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Terrascope - Demo',
        theme: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.teal,
            secondary: Colors.orange,
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: Colors.tealAccent,
            secondary: Colors.orangeAccent,
          ),
        ),
        themeMode: state.isDark ? ThemeMode.dark : ThemeMode.light,
        home: const ModeGate(),
      );
    });
  }
}

class ModeGate extends StatelessWidget {
  const ModeGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    // If user already selected farmer mode, go straight to FarmerDashboard
    if (state.mode == 'farmer') {
      return const FarmerDashboard();
    }

    // Otherwise show a quick Mode selection + signup flow
    return const ModeSelectionScreen();
  }
}

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terrascope — Choose Mode'),
        actions: [
          IconButton(
            tooltip: 'Toggle Theme',
            icon: const Icon(Icons.brightness_6),
            onPressed: () => state.toggleTheme(),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pick a mode to continue', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 12),
              ModeButton(
                label: 'Farmer Mode',
                description: 'Crops, farm alerts, irrigation suggestions',
                color: Colors.green,
                onTap: () async {
                  // Mock signup process
                  final ok = await Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen()));
                  if (ok == true) {
                    state.setMode('farmer');
                  }
                },
              ),
              const SizedBox(height: 10),
              ModeButton(
                label: 'Standard Mode',
                description: 'General weather & alerts',
                color: Colors.teal,
                onTap: () {
                  state.setMode('standard');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModeButton extends StatelessWidget {
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;
  const ModeButton({required this.label, required this.description, required this.color, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(minimumSize: const Size(300, 64), backgroundColor: color),
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(description, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Minimal mock signup to simulate flow
    final TextEditingController nameCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(decoration: const InputDecoration(labelText: 'Farm/Location (optional)')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // In real app, run auth + save profile then return true
                Navigator.pop(context, true);
              },
              child: const Text('Complete signup'),
            )
          ],
        ),
      ),
    );
  }
}

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({Key? key}) : super(key: key);

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    FarmerHomePage(),
    FarmMonitorPage(),
    AlertsPage(),
    AddonsPage(),
  ];

  void _onNav(int idx) => setState(() => _selectedIndex = idx);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Terrascope - Farmer'),
        actions: [
          IconButton(
            icon: Icon(state.isDark ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined),
            onPressed: () => state.toggleTheme(),
            tooltip: 'Toggle theme',
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'switch') {
                // go back to mode selection
                state.setMode('standard');
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'switch', child: Text('Switch mode')),
            ],
          )
        ],
      ),
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNav,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.grass), label: 'Monitor'),
          BottomNavigationBarItem(icon: Icon(Icons.notification_important), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.extension), label: 'Add-ons'),
        ],
      ),
    );
  }
}

// --- Farmer pages ---

class FarmerHomePage extends StatelessWidget {
  const FarmerHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Welcome, Farmer!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Field Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('2 fields monitored • 1 irrigation scheduled • Soil moisture OK'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(child: SmallStatBox(title: 'Temp', value: '29°C')),
            SizedBox(width: 8),
            Expanded(child: SmallStatBox(title: 'Humidity', value: '64%')),
            SizedBox(width: 8),
            Expanded(child: SmallStatBox(title: 'Soil M', value: '37%')),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ActionChip(label: const Text('Start Irrigation'), onPressed: () {}),
            ActionChip(label: const Text('Request Advisory'), onPressed: () {}),
            ActionChip(label: const Text('Log Activity'), onPressed: () {}),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Recent Alerts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const AlertCard(title: 'Heavy rain predicted', subtitle: 'Chance 80% — next 6 hours'),
        const AlertCard(title: 'Frost risk', subtitle: 'Low temps tonight'),
      ],
    );
  }
}

class FarmMonitorPage extends StatelessWidget {
  const FarmMonitorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This page would show sensor map, per-field widgets, irrigation schedule, etc.
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('Farm Monitor', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Card(child: Padding(padding: EdgeInsets.all(12), child: Text('Map / Field Tiles (placeholder)'))),
        SizedBox(height: 12),
        Card(child: Padding(padding: EdgeInsets.all(12), child: Text('Sensor Readings (placeholder)'))),
      ],
    );
  }
}

class AlertsPage extends StatelessWidget {
  const AlertsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('Alerts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        AlertCard(title: 'Flood warning', subtitle: 'River levels rising'),
        AlertCard(title: 'Pest advisory', subtitle: 'Locusts reported nearby'),
      ],
    );
  }
}

class AddonsPage extends StatelessWidget {
  const AddonsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Add-ons & Pro Features', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        FeatureTile(title: 'Crop Disease Detector', subtitle: 'Upload a photo to check for disease'),
        FeatureTile(title: 'Irrigation Automation', subtitle: 'Auto-run pumps on thresholds'),
        FeatureTile(title: 'Market Prices', subtitle: 'Local market price trends'),
      ],
    );
  }
}

// --- Small reusable widgets ---

class SmallStatBox extends StatelessWidget {
  final String title;
  final String value;
  const SmallStatBox({required this.title, required this.value, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const AlertCard({required this.title, required this.subtitle, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.warning_amber_rounded),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
      ),
    );
  }
}

class FeatureTile extends StatelessWidget {
  final String title;
  final String subtitle;
  const FeatureTile({required this.title, required this.subtitle, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(onPressed: () {}, child: const Text('Enable')),
      ),
    );
  }
}
