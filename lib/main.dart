import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:terra_scope_apk/providers/mode_provider.dart';
import 'package:terra_scope_apk/Screens/main_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ModeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}
