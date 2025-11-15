import 'package:flutter/material.dart';

class ModeProvider extends ChangeNotifier {
  String _currentMode = "normal"; //default mode

  String get currentMode => _currentMode;

  void setMode(String newMode) {
    _currentMode = newMode;
    notifyListeners();
  }
}
