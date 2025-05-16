import 'package:flutter/material.dart';
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
            _showGlitchEffect(context);
          },
          description: 'Make the screen appear broken',
        ),

        // Flashlight Strobe
        Feature(
          name: 'Flashlight Strobe',
          icon: Icons.flashlight_on,
          onTap: () {
            HapticFeedbackHelper.mediumImpact();
            _showFlashlightWarning(context);
          },
          description: 'Flash the device flashlight',
          tag: 'New',
          color: Colors.amber,
        ),
      ],
    );
  }

  /// Show a temporary screen glitch effect
  static void _showGlitchEffect(BuildContext context) {
    // This would be implemented to create a screen glitch effect
    // For now, we'll just show a dialog explaining the feature is coming soon
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Screen Glitch'),
            content: const Text(
              'This feature will make the screen appear to glitch and break temporarily. Coming in the next update!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  /// Show flashlight strobe warning
  static void _showFlashlightWarning(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('⚠️ Warning: Flashlight Strobe'),
            content: const Text(
              'This feature will rapidly flash your device\'s flashlight. It may trigger seizures in people with photosensitive epilepsy. Use with caution and never point directly at someone\'s eyes.\n\nThis feature requires camera permissions.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Implementation would go here requesting permission and controlling flashlight
                  // For now, we just show another dialog
                  _showFlashlightComingSoon(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('I Understand, Continue'),
              ),
            ],
          ),
    );
  }

  /// Show flashlight coming soon
  static void _showFlashlightComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Coming Soon'),
            content: const Text(
              'The flashlight strobe feature will be available in the next update!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
