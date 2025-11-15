import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:terra_scope_apk/Services/notification_service.dart';
import 'firebase_options.dart';

import 'Screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  String? token = await NotificationService.getDeviceToken();
  print("FCM device token :$token");

  runApp(const TerraScopeApp());
}

class TerraScopeApp extends StatelessWidget {
  const TerraScopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
