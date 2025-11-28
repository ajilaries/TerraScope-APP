import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:terra_scope_apk/Screens/commute/commute_dashboard.dart';
import 'package:terra_scope_apk/Screens/farmer/farmer_dashboard.dart';
import 'package:terra_scope_apk/Screens/home_screen0.dart';
import 'package:terra_scope_apk/Screens/main_page.dart';
import 'package:terra_scope_apk/Screens/traveler/traveler_dashboard.dart';
import 'firebase_options.dart';
import 'package:terra_scope_apk/Screens/traveler/traveler_dashboard.dart';

import 'providers/mode_provider.dart';
// import 'Screens/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ModeProvider()..loadMode(),
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

      home: const MainPage(),
    );
  }
}
