import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/sound_model.dart';
import '../models/sound_category.dart';
import '../services/sound_service.dart';
import '../utils/haptic_feedback_helper.dart';
import '../utils/ui_feedback_helper.dart';

class SoundButton extends StatefulWidget {
  final SoundModel sound;
  final bool showFavoriteButton;
  final bool showPlayingIndicator;
  final bool showDownloadButton;
  final bool isCompact;
  final Color? backgroundColor;
  final VoidCallback? onLongPress;

  const SoundButton({
    Key? key,
    required this.sound,
    this.showFavoriteButton = true,
    this.showPlayingIndicator = true,
    this.showDownloadButton = false,
    this.isCompact = false,
    this.backgroundColor,
    this.onLongPress,
  }) : super(key: key);

  @override
  State<SoundButton> createState() => _SoundButtonState();
}

class _SoundButtonState extends State<SoundButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isPlaying = false;
  bool _isTouched = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get services from provider
    final soundService = Provider.of<SoundService>(context);
    _isPlaying =
        soundService.currentPlayingSoundId == widget.sound.id &&
        soundService.isPlaying;

    // Determine button color based on sound category or custom color
    final baseColor = widget.backgroundColor ?? _getCategoryColor();

    // Create gradient colors
    final gradientColors =
        _isPlaying
            ? [baseColor, baseColor.withOpacity(0.7)]
            : [baseColor, baseColor.withOpacity(0.8)];

    final cardRadius = widget.isCompact ? 16.0 : 20.0;

    return StreamBuilder<AudioState>(
      stream: soundService.audioStateStream,
      builder: (context, snapshot) {
        // Update playing state based on audio stream
        if (snapshot.hasData) {
          _isPlaying =
              snapshot.data!.currentSoundId == widget.sound.id &&
              snapshot.data!.isPlaying;
        }

        return GestureDetector(
          onTapDown: (_) {
            setState(() => _isTouched = true);
            _animationController.forward();
          },
          onTapUp: (_) {
            setState(() => _isTouched = false);
            _animationController.reverse();
          },
          onTapCancel: () {
            setState(() => _isTouched = false);
            _animationController.reverse();
          },
          onTap: () => _playSound(soundService),
          onLongPress:
              widget.onLongPress ?? () => _toggleFavorite(soundService),
          child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(cardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: baseColor.withOpacity(_isTouched ? 0.2 : 0.4),
                      blurRadius: _isTouched ? 3 : 8,
                      offset:
                          _isTouched ? const Offset(0, 1) : const Offset(0, 3),
                      spreadRadius: _isTouched ? 0 : 1,
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isCompact ? 12 : 16,
                  vertical: widget.isCompact ? 12 : 16,
                ),
                child:
                    widget.isCompact
                        ? _buildCompactContent(soundService)
                        : _buildFullContent(soundService),
              )
              .animate(controller: _animationController)
              .scaleXY(begin: 1.0, end: 0.95, curve: Curves.easeInOut)
              .animate(target: _isPlaying ? 1.0 : 0.0)
              .shimmer(
                duration: const Duration(seconds: 1),
                color: Colors.white.withOpacity(0.3),
                stops: const [0, 0.5, 1.0],
                curve: Curves.easeInOut,
              ),
        );
      },
    );
  }

  // Compact button layout
  Widget _buildCompactContent(SoundService soundService) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Top row with title
        Row(
          children: [
            Expanded(
              child: Text(
                widget.sound.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Bottom row with controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Play button
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 16,
              ),
            ),

            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showFavoriteButton && widget.sound.isFavorite)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.only(right: 4),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),

                if (widget.showDownloadButton &&
                    widget.sound.soundPath.startsWith('http'))
                  GestureDetector(
                    onTap: () => _downloadSound(soundService),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.download,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),

        // Waveform (if playing)
        if (widget.showPlayingIndicator && _isPlaying)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(height: 12, child: _buildWaveformIndicator()),
          ),
      ],
    );
  }

  // Full-size button layout
  Widget _buildFullContent(SoundService soundService) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.sound.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            Row(
              children: [
                if (widget.showDownloadButton &&
                    widget.sound.soundPath.startsWith('http'))
                  GestureDetector(
                    onTap: () => _downloadSound(soundService),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      margin: const EdgeInsets.only(right: 8),
                      child: const Icon(
                        Icons.download,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                if (widget.showFavoriteButton)
                  GestureDetector(
                    onTap: () => _toggleFavorite(soundService),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        widget.sound.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            if (widget.showPlayingIndicator && _isPlaying)
              Expanded(child: _buildWaveformIndicator()),
          ],
        ),
      ],
    );
  }

  // Animated waveform indicator when sound is playing
  Widget _buildWaveformIndicator() {
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .scaleY(
                  begin: 0.4,
                  end: 1.0,
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  curve: Curves.easeInOut,
                  delay: Duration(milliseconds: index * 100),
                )
                .then()
                .scaleY(
                  begin: 1.0,
                  end: 0.3,
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  curve: Curves.easeInOut,
                ),
          ),
        ),
      ),
    );
  }

  // Play the sound
  void _playSound(SoundService soundService) {
    soundService.playSound(widget.sound);
  }

  // Toggle favorite status
  void _toggleFavorite(SoundService soundService) {
    soundService.toggleFavorite(widget.sound);
  }

  // Download the sound
  void _downloadSound(SoundService soundService) {
    soundService.downloadSound(widget.sound);

    // Provide haptic feedback
    UIFeedbackHelper.buttonTapFeedback(context);
  }

  // Get color based on sound category
  Color _getCategoryColor() {
    switch (widget.sound.category) {
      case CategoryType.phone:
        return Colors.blue;
      case CategoryType.game:
        return Colors.purple;
      case CategoryType.horror:
        return Colors.red;
      case CategoryType.meme:
        return Colors.orange;
      case CategoryType.social:
        return Colors.teal;
      case CategoryType.alarm:
        return Colors.redAccent;
      case CategoryType.favorite:
        return Colors.pink;
      default:
        return Colors.lightBlue;
    }
  }
}
