import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';

/// ViewModel for handling theme changes
class ThemeViewModel extends ChangeNotifier {
  /// Current theme data
  ThemeData _themeData;

  /// Flag for tracking if the app is in dark mode
  bool _isDarkMode = false;

  /// Constructor that initializes with the light theme
  ThemeViewModel() : _themeData = AppTheme.getTheme(isDarkMode: false) {
    _loadSettings(); // Load saved settings when created
  }

  /// Get the current theme data
  ThemeData get themeData => _themeData;

  /// Check if dark mode is enabled
  bool get isDarkMode => _isDarkMode;

  /// Toggle between light and dark themes
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _themeData = AppTheme.getTheme(isDarkMode: _isDarkMode);
    _saveSettings(); // Save settings after toggling
    notifyListeners();
  }

  /// Set theme directly (true = dark, false = light)
  void setTheme(bool darkMode) {
    if (_isDarkMode != darkMode) {
      _isDarkMode = darkMode;
      _themeData = AppTheme.getTheme(isDarkMode: _isDarkMode);
      _saveSettings();
      notifyListeners();
    }
  }

  /// Load settings from shared preferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _themeData = AppTheme.getTheme(isDarkMode: _isDarkMode);
      notifyListeners();
    } catch (e) {
      // Handle error loading theme settings
    }
  }

  /// Save settings to shared preferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
    } catch (e) {
      // Handle error saving theme settings
    }
  }
}
