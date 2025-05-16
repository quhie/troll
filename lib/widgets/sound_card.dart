import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/sound_model.dart';
import '../models/sound_category.dart';
import '../services/sound_service.dart';
import '../viewmodels/sound_viewmodel.dart';
import '../utils/app_theme.dart';
import '../utils/ui_feedback_helper.dart';
import 'download_button.dart';

/// A reusable card widget for displaying and playing sounds
class SoundCard extends StatelessWidget {
  final SoundModel sound;
  final bool isPlaying;
  final bool showCategory;
  final bool showDownloadButton;
  final bool isDownloading;
  final String downloadProgress;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final VoidCallback? onDownload;
  final VoidCallback? onFavorite;
  
  const SoundCard({
    Key? key,
    required this.sound,
    this.isPlaying = false,
    this.showCategory = false,
    this.showDownloadButton = false,
    this.isDownloading = false,
    this.downloadProgress = '',
    this.onLongPress,
    this.onTap,
    this.onPlay,
    this.onDownload,
    this.onFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final soundService = Provider.of<SoundService>(context, listen: false);
    final categoryColor = sound.category.color;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Kiểm tra nếu soundPath không hợp lệ
    final bool isValidSound = sound.soundPath.isNotEmpty && 
        (sound.soundPath.startsWith('http') || 
         sound.soundPath.startsWith('https') || 
         sound.soundPath.startsWith('assets/') ||
         sound.isLocal ||
         sound.soundPath.startsWith('/'));
    
    return Card(
      elevation: isPlaying ? 8 : 4,
      shadowColor: categoryColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isPlaying 
              ? categoryColor 
              : isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: isPlaying ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // Play sound when tapping the card (but not the action buttons)
          onTap: () {
            UIFeedbackHelper.buttonTapFeedback(context);
            
            // Skip if invalid sound
            if (!isValidSound) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invalid sound URL'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                )
              );
              return;
            }
            
            // Play the sound using the custom callback or default behavior
            if (onPlay != null) {
              onPlay!();
            } else if (onTap != null) {
              onTap!();
            } else {
              soundService.playSound(sound);
            }
          },
          onLongPress: onLongPress,
          splashColor: categoryColor.withOpacity(0.3),
          highlightColor: categoryColor.withOpacity(0.1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isPlaying 
                  ? [categoryColor.withOpacity(0.8), categoryColor]
                  : isDark 
                    ? [Colors.grey.shade900, Colors.grey.shade800] 
                    : [Colors.white, Colors.grey.shade50],
              ),
            ),
            child: Stack(
              children: [
                // Ripple effect when playing
                if (isPlaying)
                  Positioned.fill(
                    child: _buildRippleEffect(categoryColor),
                  ),
                  
                // Main content
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Icon with play indicator
                      _buildSoundIcon(categoryColor, isPlaying, isDark),
                      
                      const SizedBox(width: 16),
                      
                      // Sound info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Sound name
                            Text(
                              sound.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: isPlaying 
                                    ? Colors.white 
                                    : isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            
                            const SizedBox(height: 4),
                            
                            // Category if shown
                            if (showCategory)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8, 
                                  vertical: 2
                                ),
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  sound.category.name,
                                  style: TextStyle(
                                    color: isPlaying 
                                        ? Colors.white
                                        : isDark ? Colors.white70 : categoryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              
                            // Download progress indicator
                            if (isDownloading && downloadProgress.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      child: LinearProgressIndicator(
                                        value: double.tryParse(downloadProgress.replaceAll('%', '')) != null
                                            ? double.parse(downloadProgress.replaceAll('%', '')) / 100
                                            : null,
                                        backgroundColor: Colors.grey.withOpacity(0.2),
                                        valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      downloadProgress,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      // Action buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Favorite button
                          _buildActionButton(
                            icon: sound.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.redAccent,
                            isActive: sound.isFavorite,
                            isPlaying: isPlaying,
                            onTap: () {
                              UIFeedbackHelper.successFeedback(context);
                              if (onFavorite != null) {
                                onFavorite!();
                              } else {
                                // Use the ViewModel instead of Service directly
                                Provider.of<SoundViewModel>(context, listen: false)
                                    .toggleFavorite(sound);
                                
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      sound.isFavorite 
                                          ? 'favorite_removed'.tr()
                                          : 'favorite_added'.tr()
                                    ),
                                    backgroundColor: sound.isFavorite 
                                        ? Colors.red.shade700 
                                        : Colors.green.shade700,
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            isDark: isDark,
                            tooltip: sound.isFavorite ? 'remove_favorite'.tr() : 'favorite'.tr(),
                          ),
                          
                          // Download button
                          if (showDownloadButton && !sound.isLocal)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: isDownloading
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isDark ? Colors.white70 : categoryColor,
                                      ),
                                    ),
                                  )
                                : _buildActionButton(
                                    icon: Icons.download,
                                    color: categoryColor,
                                    isActive: false,
                                    isPlaying: isPlaying,
                                    onTap: () {
                                      UIFeedbackHelper.buttonTapFeedback(context);
                                      if (onDownload != null) {
                                        onDownload!();
                                      }
                                    },
                                    isDark: isDark,
                                    tooltip: 'download'.tr(),
                                  ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Playing indicator
                if (isPlaying)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor,
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                // Local indicator
                if (sound.isLocal)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.phone_android,
                            size: 10,
                            color: isDark ? Colors.white70 : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'local'.tr(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSoundIcon(Color categoryColor, bool isPlaying, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isPlaying 
            ? Colors.white 
            : categoryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        boxShadow: isPlaying 
            ? [
                BoxShadow(
                  color: categoryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ] 
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            _getCategoryIcon(),
            size: 28,
            color: isPlaying 
                ? categoryColor
                : isDark ? Colors.white : categoryColor,
          ),
          if (isPlaying)
            Positioned.fill(
              child: Center(
                child: Icon(
                  Icons.pause,
                  size: 14,
                  color: categoryColor,
                ),
              ),
            ),
        ],
      ),
    ).animate(target: isPlaying ? 1 : 0)
      .scale(
        begin: const Offset(1, 1),
        end: const Offset(1.1, 1.1),
        duration: 300.ms,
      );
  }

  Widget _buildRippleEffect(Color color) {
    return Center(
      child: Container()
        .animate(onPlay: (controller) => controller.repeat())
        .custom(
          duration: 2000.ms,
          builder: (context, value, child) => Container(
            width: value * 100,
            height: value * 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2 - 0.2 * value),
              border: Border.all(
                color: color.withOpacity(0.5 - 0.5 * value),
                width: 2,
              ),
            ),
          ),
        ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Function() onTap,
    required bool isDark,
    bool isActive = false,
    bool isPlaying = false,
    String? tooltip,
  }) {
    final buttonColor = isActive ? color : Colors.grey.withOpacity(0.3);
    
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: color.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              size: 22,
              color: isActive 
                  ? (isPlaying ? Colors.white : color)
                  : (isDark ? Colors.white70 : Colors.grey.shade600),
            ),
          ),
        ),
      ),
    );
  }
  
  IconData _getCategoryIcon() {
    switch (sound.category) {
      case CategoryType.phone:
        return Icons.smartphone;
      case CategoryType.game:
        return Icons.videogame_asset;
      case CategoryType.horror:
        return Icons.nightlight;
      case CategoryType.meme:
        return Icons.sentiment_very_satisfied;
      case CategoryType.social:
        return Icons.notifications_active;
      case CategoryType.alarm:
        return Icons.alarm;
      case CategoryType.favorite:
        return Icons.favorite;
      default:
        return Icons.music_note;
    }
  }
} 