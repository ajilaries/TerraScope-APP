import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'home_screen2.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});


  @override
  Widget build(BuildContext context) {
    return PageView(
      scrollDirection: Axis.horizontal,
      children: [
        HomeScreen(),//which is the main home screen 
        HomeScreen2(),//which is the footer buttons are arranged
      ],
    );
  }
}
