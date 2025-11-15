import 'package:flutter/foundation.dart';

class ModeProvider extends ChangeNotifier {
  String _mode = "normal"; // default mode

  String get mode => _mode;

  void setMode(String newMode) {
    _mode = newMode;
    notifyListeners();
  }
}
