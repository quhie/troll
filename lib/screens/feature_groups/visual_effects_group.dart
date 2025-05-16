import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/feature.dart';
import '../../utils/app_theme.dart';
import '../../utils/haptic_feedback_helper.dart';
import '../../screens/unclickable_button_view.dart';

/// Factory class for creating visual effects features group
class VisualEffectsGroup {
  /// Create a feature group containing all visual effect features
  static FeatureGroup create(BuildContext context) {
    return FeatureGroup(
      title: 'Visual Effects',
      icon: Icons.visibility,
      color: Colors.deepPurple,
      features: [
        // Unclickable Button
        Feature(
          name: 'Unclickable Button',
          icon: Icons.touch_app,
          onTap: () {
            HapticFeedbackHelper.mediumImpact();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const UnclickableButtonView(),
              ),
            );
          },
          description: 'Button that avoids being clicked',
          tag: 'Popular',
          color: Colors.blue,
        ),

        // Screen Glitch
        Feature(
          name: 'Screen Glitch',
          icon: Icons.screen_rotation,
          onTap: () {
            HapticFeedbackHelper.errorFeedback();
            _showGlitchWarning(context);
          },
          description: 'Make the screen appear broken',
        ),

        // Flashlight Strobe
        Feature(
          name: 'Flashlight Strobe',
          icon: Icons.flashlight_on,
          onTap: () {
            HapticFeedbackHelper.mediumImpact();
            _showStrobeWarning(context);
          },
          description: 'Flash the device flashlight',
          tag: 'New',
          color: Colors.amber,
        ),
      ],
    );
  }

  /// Show a temporary screen glitch effect
  static void _showGlitchWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('screen_glitch'.tr()),
        content: Text('screen_glitch_desc'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('ok'.tr()),
          ),
        ],
      ),
    );
  }

  /// Show flashlight strobe warning
  static void _showStrobeWarning(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('warning_flashlight'.tr()),
        content: Text('warning_flashlight_desc'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startStrobeEffect(context);
            },
            child: Text('understand_continue'.tr()),
          ),
        ],
      ),
    );
  }

  /// Show coming soon dialog
  static void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('coming_soon'.tr()),
        content: Text('feature_coming_soon'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('ok'.tr()),
          ),
        ],
      ),
    );
  }

  static void _startStrobeEffect(BuildContext context) {
    // Implementation would go here requesting permission and controlling flashlight
    // For now, we just show another dialog
    _showComingSoonDialog(context);
  }
}
