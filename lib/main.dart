import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:terra_scope_apk/Screens/splash_screen.dart';
import 'package:terra_scope_apk/Screens/farmer/farmer_dashboard.dart';
import 'package:terra_scope_apk/Screens/saftey/saftey_mode_screen.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/mode_provider.dart';
import 'providers/safety_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //load the .env file
  await dotenv.load(fileName: ".env");
  final googleApiKey = dotenv.env['GOOGLE_API_KEY'];
  //initialize firebase

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ModeProvider()..loadMode(),
        ),
        ChangeNotifierProvider(
          create: (_) => SafetyProvider(),
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
        '/farmer-dashboard': (context) => const FarmerDashboard(),
        '/safety-mode': (context) => const SafetyModeScreen(),
      },
    );
  }
}
