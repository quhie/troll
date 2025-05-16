import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'haptic_feedback_helper.dart';
import '../services/preferences_service.dart';
import '../services/vibration_service.dart';

/// Helper class that provides a unified way to give UI feedback (haptic + vibration)
/// during user interactions, respecting user preferences
class UIFeedbackHelper {
  /// Provide feedback for a button tap
  static Future<void> buttonTapFeedback(BuildContext context) async {
    final preferencesService = Provider.of<PreferencesService>(
      context,
      listen: false,
    );

    // First check if haptic feedback is enabled
    if (preferencesService.hapticFeedbackEnabled) {
      HapticFeedbackHelper.lightImpact();
    }

    // Then check if vibration on tap is enabled
    if (preferencesService.vibrateOnTapEnabled) {
      final vibrationService = VibrationService();
      await vibrationService.vibrateOnce();
    }
  }

  /// Provide feedback for a selection change (lighter)
  static Future<void> selectionChangeFeedback(BuildContext context) async {
    final preferencesService = Provider.of<PreferencesService>(
      context,
      listen: false,
    );

    if (preferencesService.hapticFeedbackEnabled) {
      HapticFeedbackHelper.selectionClick();
    }
  }

  /// Provide feedback for a significant action (stronger)
  static Future<void> successFeedback(BuildContext context) async {
    final preferencesService = Provider.of<PreferencesService>(
      context,
      listen: false,
    );

    if (preferencesService.hapticFeedbackEnabled) {
      HapticFeedbackHelper.mediumImpact();
    }

    if (preferencesService.vibrateOnTapEnabled) {
      final vibrationService = VibrationService();
      await vibrationService.vibrateOnce();
    }
  }

  /// Provide feedback for an error or warning (strongest)
  static Future<void> errorFeedback(BuildContext context) async {
    final preferencesService = Provider.of<PreferencesService>(
      context,
      listen: false,
    );

    if (preferencesService.hapticFeedbackEnabled) {
      HapticFeedbackHelper.heavyImpact();
    }
  }
}
