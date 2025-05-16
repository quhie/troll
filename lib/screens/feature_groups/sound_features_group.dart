import 'package:flutter/material.dart';
import '../../models/feature.dart';
import '../../utils/app_theme.dart';
import '../../utils/haptic_feedback_helper.dart';
import '../../screens/sound_flash_view.dart';
import '../../screens/custom_sound_lab_view.dart';
import '../../screens/voice_activated_view.dart';
import '../../screens/troll_alarm_view.dart';
import '../../models/sound_model.dart';
import '../../utils/constants.dart';

/// Factory class for creating sound features group
class SoundFeaturesGroup {
  /// Create a feature group containing all sound-related features
  static FeatureGroup create(BuildContext context) {
    return FeatureGroup(
      title: 'Sound Features',
      icon: Icons.music_note,
      color: AppTheme.primaryColor,
      features: [
        // Meme Sounds
        Feature(
          name: 'Meme Sounds',
          icon: Icons.emoji_emotions,
          onTap: () {
            HapticFeedbackHelper.mediumImpact();
            _navigateToSoundsView(context, 'Meme Sounds', _getMemeSounds());
          },
          description: 'Popular internet sound effects',
          tag: 'Fun',
        ),

        // Animal Sounds
        Feature(
          name: 'Animal Sounds',
          icon: Icons.pets,
          onTap: () {
            HapticFeedbackHelper.mediumImpact();
            _navigateToSoundsView(context, 'Animal Sounds', _getAnimalSounds());
          },
          description: 'Various animal noises',
        ),

        // Random SFX
        Feature(
          name: 'Random SFX',
          icon: Icons.shuffle,
          onTap: () {
            HapticFeedbackHelper.mediumImpact();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CustomSoundLabView(),
              ),
            );
          },
          description: 'Surprise sound effects',
          color: Colors.purple,
        ),

        // Voice Effects
        Feature(
          name: 'Voice Effects',
          icon: Icons.mic,
          onTap: () {
            HapticFeedbackHelper.mediumImpact();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const VoiceActivatedView(),
              ),
            );
          },
          description: 'Transform your voice',
          tag: 'Popular',
          color: AppTheme.secondaryColor,
        ),

        // Alarm Sounds
        Feature(
          name: 'Alarm Sounds',
          icon: Icons.alarm,
          onTap: () {
            HapticFeedbackHelper.mediumImpact();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const TrollAlarmView()),
            );
          },
          description: 'Schedule sound pranks',
          color: Colors.orange,
        ),

        // Favorites
        Feature(
          name: 'Favorites',
          icon: Icons.favorite,
          onTap: () {},
          description: 'Your saved sounds',
          color: Colors.red,
        ),
      ],
    );
  }

  /// Navigate to sound flash view with filtered sounds
  static void _navigateToSoundsView(
    BuildContext context,
    String title,
    List<SoundModel> sounds,
  ) {
    if (sounds.isEmpty) return;

    // Show first sound but provide a way to browse all in category
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => SoundFlashView(
              title: sounds[0].name,
              soundPath: sounds[0].soundPath,
              iconName: sounds[0].iconName,
              categoryTitle: title,
              categorySounds: sounds,
            ),
      ),
    );
  }

  /// Get meme-related sounds
  static List<SoundModel> _getMemeSounds() {
    final allSounds = Constants.getSoundsList();
    return allSounds
        .where(
          (sound) =>
              sound.id.contains('fart') ||
              sound.id.contains('explosion') ||
              sound.id.contains('glass'),
        )
        .toList();
  }

  /// Get animal sounds
  static List<SoundModel> _getAnimalSounds() {
    final allSounds = Constants.getSoundsList();
    return allSounds
        .where(
          (sound) =>
              sound.id.contains('mosquito') ||
              sound.id.contains('dog') ||
              sound.id.contains('cat'),
        )
        .toList();
  }
}
