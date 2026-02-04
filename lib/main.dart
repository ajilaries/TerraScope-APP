import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workmanager/workmanager.dart';
import 'package:terra_scope_apk/Screens/splash_screen.dart';
import 'package:terra_scope_apk/Screens/login_screen.dart';
import 'package:terra_scope_apk/Screens/farmer/farmer_dashboard.dart';
import 'package:terra_scope_apk/Screens/saftey/saftey_mode_screen.dart';
import 'package:terra_scope_apk/Screens/care/care_dashboard.dart';
import 'package:terra_scope_apk/Screens/traveler/traveler_dashboard.dart';
import 'package:terra_scope_apk/Screens/daily_planner/daily_planner_dashboard.dart';
import 'package:terra_scope_apk/Screens/care/emergency_contacts.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/mode_provider.dart';
import 'providers/safety_provider.dart';
import 'providers/emergency_provider.dart';
import 'Services/auth_service.dart';
import 'Services/fcm_service.dart';
import 'Services/anomaly_monitoring_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Workmanager for background tasks
  await Workmanager().initialize(
    AnomalyMonitoringService.callbackDispatcher,
    isInDebugMode: false,
  );

  //load the .env file
  await dotenv.load(fileName: ".env");
  //initialize firebase

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize FCM service
  await FCMService.initialize();

  // Initialize anomaly monitoring service
  await AnomalyMonitoringService.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ModeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SafetyProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => EmergencyProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final modeProvider = Provider.of<ModeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Terrascope",

      // 🔥 This line enables auto theme switching
      themeMode: modeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[900],
      ),

      home: const SplashScreen(),

      // Add named routes
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/farmer-dashboard': (context) => const FarmerDashboard(),
        '/safety-mode': (context) => const SafetyModeScreen(),
        '/care-dashboard': (context) => const CareDashboard(),
        '/emergency-contacts': (context) => EmergencyContactsScreen(),
        '/traveler-dashboard': (context) => const TravelerDashboard(),
        '/daily-planner-dashboard': (context) => const DailyPlannerDashboard(),
      },
    );
  }
}
