import 'package:flutter/material.dart';
import 'package:flutter_chat_app/themes/dark_mode.dart';
import 'package:flutter_chat_app/themes/light_mode.dart';

class ModeProvider extends ChangeNotifier {
  ThemeData _currentMode = lightTheme;

  ThemeData get currentMode => _currentMode;
  bool get isDarkMode => _currentMode == darkTheme;

  set currentMode(ThemeData mode) {
    if (mode == darkTheme || mode == lightTheme) {
      _currentMode = mode;
      notifyListeners();
    }
  }

  void toggleMode() {
    if (_currentMode == darkTheme) {
      _currentMode = lightTheme;
    } else {
      _currentMode = darkTheme;
    }
    notifyListeners();
  }
}
