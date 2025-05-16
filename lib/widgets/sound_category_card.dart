import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/sound_category.dart';
import '../utils/ui_feedback_helper.dart';

class SoundCategoryCard extends StatefulWidget {
  final SoundCategory category;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showItemCount;
  final bool useAnimatedTransition;

  const SoundCategoryCard({
    Key? key,
    required this.category,
    required this.onTap,
    this.isSelected = false,
    this.showItemCount = true,
    this.useAnimatedTransition = true,
  }) : super(key: key);

  @override
  State<SoundCategoryCard> createState() => _SoundCategoryCardState();
}

class _SoundCategoryCardState extends State<SoundCategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Select colors for card based on theme and selection state
    final cardColor =
        widget.isSelected
            ? widget.category.color.withOpacity(isDarkMode ? 0.7 : 0.9)
            : isDarkMode
            ? Colors.grey[800]!
            : Colors.white;

    final textColor =
        widget.isSelected
            ? Colors.white
            : isDarkMode
            ? Colors.white
            : Colors.black87;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          _controller.forward(from: 0);
          // Add haptic and vibration feedback
          UIFeedbackHelper.selectionChangeFeedback(context);
          widget.onTap();
        },
        child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color:
                        widget.isSelected
                            ? widget.category.color.withOpacity(0.4)
                            : Colors.black.withOpacity(0.05),
                    blurRadius: _isHovered ? 8 : 4,
                    offset:
                        _isHovered ? const Offset(0, 4) : const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                children: [
                  // Category icon with background
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          widget.isSelected
                              ? Colors.white.withOpacity(0.3)
                              : widget.category.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.category.icon,
                      color:
                          widget.isSelected
                              ? Colors.white
                              : widget.category.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Category name and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category.name,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (widget.category.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.category.description,
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Sound count badge
                  if (widget.showItemCount)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            widget.isSelected
                                ? Colors.white.withOpacity(0.3)
                                : widget.category.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.category.sounds.length}',
                        style: TextStyle(
                          color:
                              widget.isSelected
                                  ? Colors.white
                                  : widget.category.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            )
            .animate(controller: _controller)
            .scaleXY(
              begin: 1.0,
              end: 0.98,
              curve: Curves.easeInOut,
              duration: 100.ms,
            )
            .then()
            .scaleXY(
              begin: 0.98,
              end: 1.0,
              curve: Curves.bounceOut,
              duration: 200.ms,
            ),
      ),
    );
  }
}

/// A compact version of the category card for grid views
class SoundCategoryGridCard extends StatelessWidget {
  final SoundCategory category;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showItemCount;

  const SoundCategoryGridCard({
    Key? key,
    required this.category,
    required this.onTap,
    this.isSelected = false,
    this.showItemCount = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Select colors for card based on theme and selection state
    final cardColor =
        isSelected
            ? category.color
            : isDarkMode
            ? Colors.grey[800]!
            : Colors.white;

    final textColor =
        isSelected
            ? Colors.white
            : isDarkMode
            ? Colors.white
            : Colors.black87;

    return GestureDetector(
      onTap: () {
        // Add haptic and vibration feedback
        UIFeedbackHelper.selectionChangeFeedback(context);
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? category.color.withOpacity(0.4)
                      : Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? Colors.white.withOpacity(0.3)
                        : category.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                color: isSelected ? Colors.white : category.color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            // Category name
            Text(
              category.name,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (showItemCount) ...[
              const SizedBox(height: 6),
              // Sound count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Colors.white.withOpacity(0.3)
                          : category.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${category.sounds.length} sounds',
                  style: TextStyle(
                    color: isSelected ? Colors.white : category.color,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ).animate(
        onPlay: (controller) => controller.repeat(reverse: true),
        effects: [
          isSelected
              ? ScaleEffect(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.05, 1.05),
                duration: const Duration(milliseconds: 2000),
                curve: Curves.easeInOut,
              )
              : const FadeEffect(duration: Duration(milliseconds: 0)),
        ],
      ),
    );
  }
}
