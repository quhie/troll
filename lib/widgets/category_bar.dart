import 'package:flutter/material.dart';
import '../models/sound_category.dart';

/// A horizontal scrollable bar of categories for the app
class CategoryBar extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final bool showIcons;

  const CategoryBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.showIcons = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          // Gradient colors based on theme
          final gradientColors =
              isSelected
                  ? isDark
                      ? [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.7),
                      ]
                      : [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.8),
                      ]
                  : isDark
                  ? [Colors.grey[800]!, Colors.grey[900]!]
                  : [Colors.white, Colors.grey[100]!];

          // Get icon for category
          IconData iconData = _getIconForCategory(category);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onCategorySelected(category),
                borderRadius: BorderRadius.circular(30),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.3,
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : [
                              BoxShadow(
                                color: isDark ? Colors.black26 : Colors.black12,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                  ),
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 100),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (showIcons)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                iconData,
                                size: 20,
                                color:
                                    isSelected
                                        ? theme.colorScheme.onPrimary
                                        : isDark
                                        ? Colors.white.withOpacity(0.9)
                                        : Colors.black.withOpacity(0.8),
                              ),
                            ),
                          Text(
                            category.isEmpty ? 'Tất cả' : category,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? theme.colorScheme.onPrimary
                                      : isDark
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.black.withOpacity(0.8),
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              fontSize: 13,
                              letterSpacing: 0.3,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    final lowerCase = category.toLowerCase();

    if (lowerCase.isEmpty) return Icons.apps;
    if (lowerCase.contains('nhạc') || lowerCase.contains('music'))
      return Icons.music_note;
    if (lowerCase.contains('anime')) return Icons.style;
    if (lowerCase.contains('game')) return Icons.videogame_asset;
    if (lowerCase.contains('meme')) return Icons.sentiment_very_satisfied;
    if (lowerCase.contains('phim') || lowerCase.contains('movie'))
      return Icons.movie;
    if (lowerCase.contains('hiệu ứng') || lowerCase.contains('sound effects'))
      return Icons.surround_sound;
    if (lowerCase.contains('reactions')) return Icons.emoji_emotions;
    if (lowerCase.contains('thú vị') || lowerCase.contains('interesting'))
      return Icons.auto_awesome;
    if (lowerCase.contains('tiktok')) return Icons.music_video;
    if (lowerCase.contains('trào lưu') || lowerCase.contains('trends'))
      return Icons.trending_up;
    if (lowerCase.contains('động vật') || lowerCase.contains('animal'))
      return Icons.pets;
    if (lowerCase.contains('tiếng kêu') || lowerCase.contains('sound'))
      return Icons.volume_up;

    return Icons.category;
  }
}
