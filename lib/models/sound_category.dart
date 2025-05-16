import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'sound_model.dart';

/// Represents a category of sounds
class SoundCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final List<SoundModel> sounds;
  final bool isExpandable;

  SoundCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.sounds,
    this.isExpandable = true,
  });
}

/// Sound category types matching the requirements
enum CategoryType { phone, game, horror, meme, social, alarm, favorite, trending, recent, best }

/// Extension to get category details
extension CategoryTypeExtension on CategoryType {
  String get name {
    switch (this) {
      case CategoryType.phone:
        return 'Phone / Device';
      case CategoryType.game:
        return 'Game Sounds';
      case CategoryType.horror:
        return 'Horror Sounds';
      case CategoryType.meme:
        return 'Meme / Funny';
      case CategoryType.social:
        return 'Social Media';
      case CategoryType.alarm:
        return 'Alarm Sounds';
      case CategoryType.favorite:
        return 'Favorites';
      case CategoryType.trending:
        return 'Trending';
      case CategoryType.recent:
        return 'Recent';
      case CategoryType.best:
        return 'Best';
    }
  }
  
  // Tên danh mục đã được dịch dựa trên ngôn ngữ hiện tại
  String get localizedName {
    switch (this) {
      case CategoryType.phone:
        return tr('phone_device');
      case CategoryType.game:
        return tr('game_sounds');
      case CategoryType.horror:
        return tr('horror_sounds');
      case CategoryType.meme:
        return tr('meme_funny');
      case CategoryType.social:
        return tr('social_media');
      case CategoryType.alarm:
        return tr('alarm_sounds');
      case CategoryType.favorite:
        return tr('favorite_sounds');
      case CategoryType.trending:
        return tr('trending');
      case CategoryType.recent:
        return tr('recent');
      case CategoryType.best:
        return tr('best');
    }
  }

  String get description {
    switch (this) {
      case CategoryType.phone:
        return 'Message alerts, calls, and device sounds';
      case CategoryType.game:
        return 'Game-related sound effects';
      case CategoryType.horror:
        return 'Spooky and jumpscare sounds';
      case CategoryType.meme:
        return 'Popular internet sound effects and memes';
      case CategoryType.social:
        return 'Social media and notification sounds';
      case CategoryType.alarm:
        return 'Siren and alarm sound effects';
      case CategoryType.favorite:
        return 'Your saved favorite sounds';
      case CategoryType.trending:
        return 'Currently trending sounds';
      case CategoryType.recent:
        return 'Recently added sounds';
      case CategoryType.best:
        return 'Best sounds of all time';
    }
  }

  IconData get icon {
    switch (this) {
      case CategoryType.phone:
        return Icons.smartphone;
      case CategoryType.game:
        return Icons.videogame_asset;
      case CategoryType.horror:
        return Icons.nightlight;
      case CategoryType.meme:
        return Icons.sentiment_very_satisfied;
      case CategoryType.social:
        return Icons.share;
      case CategoryType.alarm:
        return Icons.notifications_active;
      case CategoryType.favorite:
        return Icons.favorite;
      case CategoryType.trending:
        return Icons.trending_up;
      case CategoryType.recent:
        return Icons.history;
      case CategoryType.best:
        return Icons.star;
    }
  }

  Color get color {
    switch (this) {
      case CategoryType.phone:
        return Colors.blue;
      case CategoryType.game:
        return Colors.green;
      case CategoryType.horror:
        return Colors.purple;
      case CategoryType.meme:
        return Colors.amber;
      case CategoryType.social:
        return Colors.teal;
      case CategoryType.alarm:
        return Colors.red;
      case CategoryType.favorite:
        return Colors.pink;
      case CategoryType.trending:
        return Colors.orange;
      case CategoryType.recent:
        return Colors.indigo;
      case CategoryType.best:
        return Colors.deepPurple;
    }
  }
}
