import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';
import '../utils/haptic_feedback_helper.dart';

/// Service to handle user preferences and app state
class PreferencesService extends ChangeNotifier {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;

  // Keys for shared preferences
  static const String _firstRunKey = 'is_first_run';
  static const String _hapticFeedbackKey = 'haptic_feedback_enabled';
  static const String _vibrateOnTapKey = 'vibrate_on_tap_enabled';
  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _soundEffectsKey = 'sound_effects_enabled';
  static const String _highQualityAudioKey = 'high_quality_audio';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  // Default values
  bool _isFirstRun = true;
  bool _hapticFeedbackEnabled = true;
  bool _vibrateOnTapEnabled = true;
  bool _darkModeEnabled = false;
  bool _soundEffectsEnabled = true;
  bool _highQualityAudio = true;
  bool _onboardingCompleted = false;
  
  // Current theme
  ThemeData? _currentTheme;

  // Getters
  bool get isFirstRun => _isFirstRun;
  bool get hapticFeedbackEnabled => _hapticFeedbackEnabled;
  bool get vibrateOnTapEnabled => _vibrateOnTapEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  bool get soundEffectsEnabled => _soundEffectsEnabled;
  bool get highQualityAudio => _highQualityAudio;
  bool get onboardingCompleted => _onboardingCompleted;
  
  // Get current theme
  ThemeData get currentTheme => _currentTheme ?? AppTheme.getTheme(isDarkMode: _darkModeEnabled);

  PreferencesService._internal() {
    _loadPreferences();
  }

  /// Load saved preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _isFirstRun = prefs.getBool(_firstRunKey) ?? true;
      _hapticFeedbackEnabled = prefs.getBool(_hapticFeedbackKey) ?? true;
      _vibrateOnTapEnabled = prefs.getBool(_vibrateOnTapKey) ?? true;
      _darkModeEnabled = prefs.getBool(_darkModeKey) ?? false;
      _soundEffectsEnabled = prefs.getBool(_soundEffectsKey) ?? true;
      _highQualityAudio = prefs.getBool(_highQualityAudioKey) ?? true;
      _onboardingCompleted = prefs.getBool(_onboardingCompletedKey) ?? false;
      
      // Update theme based on preferences
      _currentTheme = AppTheme.getTheme(isDarkMode: _darkModeEnabled);

      // Mark as not first run anymore
      if (_isFirstRun) {
        await prefs.setBool(_firstRunKey, false);
        _isFirstRun = false;
      }
      
      // Update haptic feedback helper
      HapticFeedbackHelper.setHapticFeedbackEnabled(_hapticFeedbackEnabled);

      notifyListeners();
    } catch (e) {
      // Error loading preferences
    }
  }

  /// Set haptic feedback enabled/disabled
  Future<bool> setHapticFeedback(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hapticFeedbackKey, value);
      _hapticFeedbackEnabled = value;
      
      // Update static helper class
      HapticFeedbackHelper.setHapticFeedbackEnabled(value);
      
      // Provide feedback when enabling haptic feedback
      if (value) {
        HapticFeedbackHelper.lightImpact();
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      // Error saving haptic feedback preference
      return false;
    }
  }
  
  /// Set vibrate on tap enabled/disabled
  Future<bool> setVibrateOnTap(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_vibrateOnTapKey, value);
      _vibrateOnTapEnabled = value;
      
      // Provide feedback when enabling vibrate on tap
      if (value && _hapticFeedbackEnabled) {
        HapticFeedbackHelper.lightImpact();
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      // Error saving vibrate on tap preference
      return false;
    }
  }

  /// Set dark mode enabled/disabled
  Future<void> setDarkMode(bool value) async {
    try {
      if (_darkModeEnabled == value) return;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, value);
      _darkModeEnabled = value;
      
      // Update theme when dark mode changes
      _currentTheme = AppTheme.getTheme(isDarkMode: _darkModeEnabled);
      
      notifyListeners();
    } catch (e) {
      // Error saving dark mode preference
    }
  }

  /// Set UI sound effects enabled/disabled
  Future<void> setSoundEffects(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_soundEffectsKey, value);
      _soundEffectsEnabled = value;
      notifyListeners();
    } catch (e) {
      // Error saving sound effects preference
    }
  }

  /// Set high quality audio enabled/disabled
  Future<void> setHighQualityAudio(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_highQualityAudioKey, value);
      _highQualityAudio = value;
      notifyListeners();
    } catch (e) {
      // Error saving high quality audio preference
    }
  }

  /// Mark onboarding as completed
  Future<void> setOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompletedKey, true);
      _onboardingCompleted = true;
      notifyListeners();
    } catch (e) {
      // Error saving onboarding completion status
    }
  }

  /// Reset all preferences to defaults
  Future<void> resetAllPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Reset all settings except first run
      await prefs.setBool(_hapticFeedbackKey, true);
      await prefs.setBool(_vibrateOnTapKey, true);
      await prefs.setBool(_darkModeKey, false);
      await prefs.setBool(_soundEffectsKey, true);
      await prefs.setBool(_highQualityAudioKey, true);

      // Update local values
      _hapticFeedbackEnabled = true;
      _vibrateOnTapEnabled = true;
      _darkModeEnabled = false;
      _soundEffectsEnabled = true;
      _highQualityAudio = true;
      
      // Update haptic feedback helper
      HapticFeedbackHelper.setHapticFeedbackEnabled(true);
      
      // Update theme to match reset preferences
      _currentTheme = AppTheme.getTheme(isDarkMode: false);

      notifyListeners();
    } catch (e) {
      // Error resetting preferences
    }
  }
} 