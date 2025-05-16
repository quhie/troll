import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/preferences_service.dart';
import 'package:flutter/material.dart';

/// Helper class to standardize haptic feedback across the app
class HapticFeedbackHelper {
  /// Static tracking of haptic feedback setting
  static bool _hapticFeedbackEnabled = true;

  /// Update haptic feedback enabled state
  static void setHapticFeedbackEnabled(bool enabled) {
    _hapticFeedbackEnabled = enabled;
  }

  /// Get current haptic feedback setting
  static bool get isHapticFeedbackEnabled => _hapticFeedbackEnabled;

  /// Provides light haptic feedback for selection changes
  static void selectionClick() async {
    if (!_hapticFeedbackEnabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Provides medium haptic feedback for button presses
  static void lightImpact() async {
    if (!_hapticFeedbackEnabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Provides stronger haptic feedback for significant actions
  static void mediumImpact() async {
    if (!_hapticFeedbackEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Provides strong haptic feedback for important actions
  static void heavyImpact() async {
    if (!_hapticFeedbackEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Feedback for selection changes (for backward compatibility)
  static void selectionFeedback() async {
    if (!_hapticFeedbackEnabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Feedback for successful actions (for backward compatibility)
  static void successFeedback() async {
    if (!_hapticFeedbackEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Feedback for errors or warnings (for backward compatibility)
  static void errorFeedback() async {
    if (!_hapticFeedbackEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Trigger vibration (for backward compatibility)
  static void vibrate() async {
    if (!_hapticFeedbackEnabled) return;
    await HapticFeedback.vibrate();
  }

  /// Provides vibration feedback based on user preferences
  /// Use this as the main method for providing haptic feedback
  static void feedback(BuildContext context, HapticFeedbackType type) {
    // Check if haptic feedback is enabled in user preferences
    final preferencesService = Provider.of<PreferencesService>(
      context,
      listen: false,
    );

    if (preferencesService.hapticFeedbackEnabled) {
      switch (type) {
        case HapticFeedbackType.selection:
          selectionClick();
          break;
        case HapticFeedbackType.light:
          lightImpact();
          break;
        case HapticFeedbackType.medium:
          mediumImpact();
          break;
        case HapticFeedbackType.heavy:
          heavyImpact();
          break;
      }
    }
  }
}

/// Types of haptic feedback available in the app
enum HapticFeedbackType {
  /// Light feedback for selection changes
  selection,

  /// Medium feedback for button presses
  light,

  /// Stronger feedback for significant actions
  medium,

  /// Strong feedback for important actions
  heavy,
}
