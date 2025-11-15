import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'home_screen2.dart';
import 'home_screen0.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView(
      scrollDirection: Axis.horizontal,
      children: [
        HomeScreen0(
          onModeSelected: (mode) {
            // ADD WHAT YOU WANT TO DO WHEN A MODE IS SELECTED
            print("Selected mode: $mode");
          },
        ),
        HomeScreen(),
        HomeScreen2(),
      ],
    );
  }
}
