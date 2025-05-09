import 'package:flutter/services.dart';

/// Helper class for handling haptic feedback in the app
class HapticFeedbackHelper {
  /// Triggers light impact haptic feedback
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Triggers medium impact haptic feedback
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Triggers heavy impact haptic feedback
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Triggers selection click haptic feedback
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Triggers vibration
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }
}