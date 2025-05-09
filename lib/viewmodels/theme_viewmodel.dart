import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ThemeViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  // Get current theme data
  ThemeData getTheme(BuildContext context) {
    return isDarkMode ? AppTheme.darkTheme() : AppTheme.lightTheme();
  }
  
  // Toggle theme mode
  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
  
  // Set specific theme mode
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
} 