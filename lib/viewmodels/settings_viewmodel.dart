import 'package:flutter/foundation.dart';
import '../services/preferences_service.dart';

/// ViewModel for the settings screen
class SettingsViewModel extends ChangeNotifier {
  final PreferencesService _preferencesService;

  // Constructor
  SettingsViewModel(this._preferencesService);

  // Getters
  bool get hapticFeedbackEnabled => _preferencesService.hapticFeedbackEnabled;
  bool get vibrateOnTapEnabled => _preferencesService.vibrateOnTapEnabled;
  bool get darkModeEnabled => _preferencesService.darkModeEnabled;
  bool get soundEffectsEnabled => _preferencesService.soundEffectsEnabled;
  bool get highQualityAudio => _preferencesService.highQualityAudio;

  /// Toggle haptic feedback setting
  Future<void> toggleHapticFeedback() async {
    await _preferencesService.setHapticFeedback(!hapticFeedbackEnabled);
    notifyListeners();
  }

  /// Toggle vibrate on tap setting
  Future<void> toggleVibrateOnTap() async {
    await _preferencesService.setVibrateOnTap(!vibrateOnTapEnabled);
    notifyListeners();
  }

  /// Toggle dark mode setting
  Future<void> toggleDarkMode() async {
    await _preferencesService.setDarkMode(!darkModeEnabled);
    notifyListeners();
  }

  /// Toggle sound effects setting
  Future<void> toggleSoundEffects() async {
    await _preferencesService.setSoundEffects(!soundEffectsEnabled);
    notifyListeners();
  }

  /// Toggle high quality audio setting
  Future<void> toggleHighQualityAudio() async {
    await _preferencesService.setHighQualityAudio(!highQualityAudio);
    notifyListeners();
  }

  /// Reset all settings to defaults
  Future<void> resetSettings() async {
    await _preferencesService.resetAllPreferences();
    notifyListeners();
  }
}
