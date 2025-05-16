import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:async';
import '../models/sound_model.dart';
import '../models/sound_category.dart';
import '../utils/app_theme.dart';

/// A sound tile widget with animation effects when added to the UI.
class AnimatedSoundTile extends StatefulWidget {
  final SoundModel sound;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final Duration delay;

  const AnimatedSoundTile({
    Key? key,
    required this.sound,
    required this.isPlaying,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.delay,
  }) : super(key: key);

  @override
  State<AnimatedSoundTile> createState() => _AnimatedSoundTileState();
}

class _AnimatedSoundTileState extends State<AnimatedSoundTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  Timer? _autoDisableTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(_controller);

    if (widget.isPlaying) {
      _controller.forward();
      _startAutoDisableTimer();
    }

    // Delay the animation based on the item's position
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _autoDisableTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedSoundTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.forward();
        _startAutoDisableTimer();
      } else {
        _controller.reverse();
        _autoDisableTimer?.cancel();
      }
    }
  }

  void _startAutoDisableTimer() {
    _autoDisableTimer?.cancel();
    _autoDisableTimer = Timer(const Duration(seconds: 3), () {
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use a fixed icon based on category instead of parsing the string
    final IconData iconData = _getCategoryIcon();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(scale: _scaleAnimation.value, child: child),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Sound icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    iconData,
                    color: AppTheme.primaryColor,
                    size: 30,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Sound info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.sound.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.sound.category.name.tr(),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                
                // Playing indicator
                if (widget.isPlaying)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volume_up,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Helper method to get an icon based on category
  IconData _getCategoryIcon() {
    switch (widget.sound.category) {
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
