import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../Services/auth_service.dart';

class ModeProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<String?> _getUserId() async {
    final token = await _authService.getSavedToken();
    if (token != null) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        return decodedToken['user_id'] ??
            decodedToken['id'] ??
            decodedToken['sub'];
      } catch (e) {
        print('Error decoding JWT: $e');
        return null;
      }
    }
    return null;
  }

  // ---------------------- 🌗 THEME MODE ----------------------
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    final userId = await _getUserId();
    if (userId != null) {
      await _firestore.collection('users').doc(userId).set({
        'dark_mode': _isDarkMode,
      }, SetOptions(merge: true));
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dark_mode', _isDarkMode);
    }
  }

  Future<void> loadTheme() async {
    final userId = await _getUserId();
    if (userId != null) {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        _isDarkMode = doc.data()!['dark_mode'] ?? false;
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
    }
    notifyListeners();
  }

  // ---------------------- 🎛️ APP MODE (farm/travel/safety) ----------------------
  String _mode = "default";
  String get mode => _mode;

  void setMode(String newMode) async {
    _mode = newMode;
    notifyListeners();

    final userId = await _getUserId();
    if (userId != null) {
      await _firestore.collection('users').doc(userId).set({
        'user_mode': newMode,
      }, SetOptions(merge: true));
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_mode', newMode);
    }
  }

  Future<void> loadMode() async {
    final userId = await _getUserId();
    if (userId != null) {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        _mode = doc.data()!['user_mode'] ?? "default";
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      _mode = prefs.getString('user_mode') ?? "default";
    }
    notifyListeners();
  }
}
