import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModeProvider extends ChangeNotifier {
  String _mode = "default";
  String get mode => _mode;

  void setMode(String newMode) async {
    _mode = newMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_mode', newMode);
  }

  Future<void> loadMode() async {
    final prefs = await SharedPreferences.getInstance();
    _mode = prefs.getString('user_mode') ?? "default";
    notifyListeners();
  }
}
