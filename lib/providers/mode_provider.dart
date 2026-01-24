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
    try {
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
    } catch (e) {
      print('Error loading theme: $e');
      // Set default on error
      _isDarkMode = false;
    }
    notifyListeners();
  }

  // ---------------------- 🎛️ APP MODE (farm/travel/safety) ----------------------
  String _mode = "default";
  String get mode => _mode;

  List<String> _recentModes = [];
  List<String> get recentModes => _recentModes;

  void setMode(String newMode) async {
    _mode = newMode;
    // Add to recent modes, keep only last 3
    _recentModes.remove(newMode);
    _recentModes.insert(0, newMode);
    if (_recentModes.length > 3) {
      _recentModes = _recentModes.sublist(0, 3);
    }
    notifyListeners();

    final userId = await _getUserId();
    if (userId != null) {
      await _firestore.collection('users').doc(userId).set({
        'user_mode': newMode,
        'recent_modes': _recentModes,
      }, SetOptions(merge: true));
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_mode', newMode);
      await prefs.setStringList('recent_modes', _recentModes);
    }
  }

  Future<void> loadMode() async {
    try {
      final userId = await _getUserId();
      if (userId != null) {
        final doc = await _firestore.collection('users').doc(userId).get();
        if (doc.exists && doc.data() != null) {
          _mode = doc.data()!['user_mode'] ?? "default";
          _recentModes = List<String>.from(doc.data()!['recent_modes'] ?? []);
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        _mode = prefs.getString('user_mode') ?? "default";
        _recentModes = prefs.getStringList('recent_modes') ?? [];
      }
    } catch (e) {
      print('Error loading mode: $e');
      // Set defaults on error
      _mode = "default";
      _recentModes = [];
    }
    notifyListeners();
  }
}
